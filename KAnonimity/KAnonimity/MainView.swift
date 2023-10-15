import SwiftUI
import CSV

struct CSVFileManager {
    fileprivate var incsv: CSVReader
    fileprivate var outcsv: CSVWriter
    fileprivate var headerRow: [String]
    public var data: [String: [String]] = ["Full Name": [],
                                           "Phone": [],
                                           "Address": [],
                                           "Profession": [],
                                           "Salary": []]
    
    public mutating func deleteData(forKey key: String) {
        data.removeValue(forKey: key)
    }
    
    public var getData: [String: [String]] {
        get { return data }
    }
    
    public mutating func readData() {
        while let row = self.incsv.next() {
            data["Full Name"]!.append(row[0])
            data["Phone"]!.append(row[1])
            data["Address"]!.append(row[2])
            data["Profession"]!.append(row[3])
            data["Salary"]!.append(row[4])
        }
    }
    
    public func writeData(row: [String], closing: Bool = false) throws {
        try self.outcsv.write(row: row)
        if closing {self.outcsv.stream.close() }
    }
    
    public init(from url: URL) {
        _ = url.startAccessingSecurityScopedResource()
        
        /// creating path of new csv file
        let fm = FileManager.default
        let outPath = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].standardizedFileURL.appendingPathComponent("anon\(url.lastPathComponent)", conformingTo: .database).standardizedFileURL.path()
        guard let outStream = OutputStream(toFileAtPath: outPath, append: false) else {
            /// unknowed error: probably because of the filemanager
            fatalError("Creating OutputStream with new csv path has cause an unknowed error")
        }
        do { self.outcsv = try CSVWriter(stream: outStream) }
        catch {
            fatalError("Creating OutputCSV with new csv path has cause an unknowed error")
        }
        
        guard let inStream = InputStream(fileAtPath: url.path()) else {
            fatalError("Given csv file url is broken or changed")
        }
        do { self.incsv = try CSVReader(stream: inStream) }
        catch {
            fatalError("Given csv file url is broken or changed")
        }
        guard let header = self.incsv.next() else {
            fatalError("Csv file is broken or empty")
        }
        self.headerRow = header
    }
}

struct HeaderPickerView: View {
    @Binding var CSVManager: CSVFileManager?
    @Binding var selected: [String]
    @Binding var items: [String]
    
    var body: some View {
        Form {
            List {
                ForEach(items, id: \.self) { item in
                    Button(action: {
                        withAnimation {
                            if self.selected.contains(item) {
                                self.selected.remove(at: self.selected.firstIndex(of: item)!
                                )
                            } else {
                                self.selected.append(item)
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                                .opacity(self.selected.contains(item) ? 1.0 : 0.0)
                            Text(item)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

struct MultiHeaderPickerView: View {
    @Binding var CSVManager: CSVFileManager?
    @Binding var selected: [String]
    @Binding var items: [String]
    
    @State var showingPopover = false
    
    var body: some View {
        Form {
            HStack() {
                Text("Select identificators:")
                    .foregroundStyle(.white)
                Button(action: {
                    showingPopover.toggle()
                }) {
                    HStack {
                        Spacer()
                        Text("Press to set")
                            .foregroundStyle(.gray)
                        Spacer()
                        Image(systemName: "\(selected.count).circle")
                            .font(.title2)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(Color(red: 0.4192, green: 0.2358, blue: 0.3450))
                }
                
                .popover(isPresented: $showingPopover) {
                    withAnimation {
                        HeaderPickerView(CSVManager: $CSVManager, selected: $selected, items: $items)
                            .frame(width: 300)
                    }
                }
            }
            
            Text("Selected:")
                .foregroundStyle(.white)
            if (selected.count > 0) {
                withAnimation {
                    Text("\t* \(selected.joined(separator: "\n\t* "))")
                        .foregroundStyle(.white)
                }
            }
        }
        .padding()
        .background(Color(red: 0.4192, green: 0.2358, blue: 0.3450))
        .navigationTitle("Selecting identificators")
    }
}

struct MainView: View {
    @State var isShowing = false
    @State var CSVManager: CSVFileManager?
    @State var selectedHeader = [String]()
    @State var headerKanon = [String]()
    @State var kValue: String = "10"
    @State var kanon: Kanonimity?
    @State var wrongIdents = false
    
    var body: some View {
        VStack {
            if (CSVManager == nil) {
                Text("Welcome, dude!")
            } else {
                VStack {
                    MultiHeaderPickerView(CSVManager: $CSVManager, selected: $selectedHeader, items: $headerKanon)
                    HStack {
                        Text("k value")
                        TextField("hey key", text: $kValue)
                            .frame(width: 50)
                    }
                    
                    .onChange(of: selectedHeader.count) { _, count in
                        if count < 2 { wrongIdents = true }
                        else { wrongIdents = false }
                    }
                    
                    Button("Let's go", action: {
                        if !wrongIdents {
                            kanon = Kanonimity(csvManager: $CSVManager, kValue: Int(kValue)!, identificators: selectedHeader)
                            kanon!.anonimize()
                        }
                    })
                    Text(wrongIdents ? "Wrong data" : " ")
                    if (kanon != nil && kanon!.k != 0) {
                        Text("\(kanon!.k)")
                    }
                    
                }
                Spacer()
                VStack {
                    if (kanon != nil && kanon!.uniqueRowCount != 0) {
                        Text("Unique rows: \(kanon!.uniqueRowCount)")
                    }
                    ForEach(1..<6) { number in
                        HStack {
                            Text("\(number):")
                                .bold()
                            Spacer()
                            if kanon != nil && number - 1 < kanon!.top5.count {
                                let number = kanon!.top5[number - 1]
                                Text("\(number) %")
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        
        .toolbar {
            ToolbarItem() {
                Button { isShowing = true } label: {
                    Label("Import file", systemImage: "square.and.arrow.down")
                }
            }
        }
        .fileImporter(isPresented: $isShowing, allowedContentTypes: [.item], allowsMultipleSelection: false, onCompletion: { result in
            
            switch result {
            case .success(let fileurls):
                print(fileurls.first!.path())
                CSVManager = CSVFileManager(from: fileurls.first!)
                headerKanon = CSVManager!.headerRow
                headerKanon.remove(at: 0); headerKanon.remove(at: 0)
            case .failure(let error):
                print(error)
            }
        })
    }
}

#Preview {
    MainView()
}
