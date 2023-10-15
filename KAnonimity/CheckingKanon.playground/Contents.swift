import Foundation
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
        let outPath = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].standardizedFileURL.appendingPathComponent("new.csv", conformingTo: .database).standardizedFileURL.path()
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


let fm = FileManager.default
let csvPath = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].standardizedFileURL.appendingPathComponent("example50.csv", conformingTo: .database).standardizedFileURL

var manager = CSVFileManager(from: csvPath)

class Kanonimity {
    private var csvManager: CSVFileManager
    private var identificators: Set<String>
    private var preferkValue: Int
    
    public init(csvManager: CSVFileManager, kValue: Int, identificators: [String]) {
        self.csvManager = csvManager
        self.preferkValue = kValue
        self.identificators = Set(identificators)
    }
    
    public func anonimize() {
        self.readData()
        let data = csvManager.data
        
        chooseAndDoMethods()
    }
    
    private func kValues() -> [String] {
        var gropsCount = [ [[String]: Int](),[[String]: Int](),[[String]: Int](),[[String]: Int]() ]
        var minValue = [Int.max, Int.max, Int.max, Int.max]
        
        var row = [String]()
        row.append(csvManager.data["Address"]![0])
        row.append(csvManager.data["Profession"]![0])
        row.append(csvManager.data["Salary"]![0])
        
        
        gropsCount[0] = [ row: 1 ]
        
        gropsCount[1] = [ row.dropLast(): 1 ]
        
        var tmp = row
        tmp.remove(at: 1)
        gropsCount[2][tmp] = 1
    
        
        row.remove(at: 0)
        gropsCount[3] = [ row: 1 ]
        
        tmp = [String]()
        for rowIndex in 1..<csvManager.data["Phone"]!.count {
            row = [String]()
            row.append(csvManager.data["Address"]![rowIndex])
            row.append(csvManager.data["Profession"]![rowIndex])
            row.append(csvManager.data["Salary"]![rowIndex])
            
            if let count = gropsCount[0][row] {
                gropsCount[0][row] = count + 1
            } else {
                gropsCount[0][row] = 1
            }
            
            tmp = row
            tmp.remove(at: 2)
            if let count = gropsCount[1][tmp] {
                gropsCount[1][tmp] = count + 1
            } else {
                gropsCount[1][tmp] = 1
            }
            
            tmp = row
            tmp.remove(at: 1)
            if let count = gropsCount[2][tmp] {
                gropsCount[2][tmp] = count + 1
            } else {
                gropsCount[2][tmp] = 1
            }
            
            tmp = row
            tmp.remove(at: 0)
            if let count = gropsCount[3][tmp] {
                gropsCount[3][tmp] = count + 1
            } else {
                gropsCount[3][tmp] = 1
            }
        }
        
        for index in 0..<4 {
            for (_, count) in gropsCount[index] {
                if count < minValue[index] { minValue[index] = count }
            }
        }
        return minValue.map { String($0) }
        
    }
    
    public var mainkValue: Int {
        get {
            var gropsCount = [[String] : Int]()
            var minValue = Int.max
            
            for rowIndex in 0..<self.csvManager.data["Phone"]!.count {
                var row = [String]()
                for ident in self.identificators {
                    if let _ = self.csvManager.data[ident] {
                        row.append(self.csvManager.data[ident]![rowIndex])
                    }
                }
                if let _ = gropsCount[row] {
                    gropsCount[row] = gropsCount[row]! + 1
                } else {
                    gropsCount[row] = 1
                }
            }
            
            for (value, count) in gropsCount {
                if (count == 1) { print(value) }
                if count < minValue { minValue = count }
            }
            return minValue
        }
    }
    
    private var IT = Set(arrayLiteral: "Frontend разработчик", "iOS разработчик", "Backend разработчик")
    private var Economy = Set(arrayLiteral: "Бизнес-менеджер", "Бизнес-аналитик", "Ген. директор")
    private var Building = Set(arrayLiteral: "Строитель", "Прораб", "Водитель стройтехники")
    private var Surving = Set(arrayLiteral: "Уборщик", "Охраник", "Секретарь", "Официант")
    private var Med = Set(arrayLiteral: "Медик", "Хирург", "Главный Хирург")
    private func professionSector(for prof: String) -> String {
        if IT.contains(prof) { return "IT" }
        if Economy.contains(prof) { return "Економика" }
        if Building.contains(prof) { return "Строительство" }
        if Surving.contains(prof) { return "Обслуживание" }
        return "Медицина"
    }
    private func salarySector(for salary: String) -> String {
        var salary: Int = Int(salary)!
        if (salary < 50000) { return "Низкая" }
        if (salary >= 50000 && salary < 150000) { return "Средняя" }
        return "Высокая"
    }
    
    private func chooseAndDoMethods() {
        methodDeleteAttribute(for: "Full Name")
        methodMask(for: "Phone")
        
        if identificators.count == 3 {
            methodPseudonameAddress()
            methodCommonationLiteAddress()
            methodPseudonameProfession()
            methodPseudonameSalary()
//            if mainkValue < preferkValue { methodCommonationHardAddress() }
        }
        else if identificators.count == 2 {
            if identificators.contains("Address") && identificators.contains("Profession") {
                methodPseudonameAddress()
                methodCommonationLiteAddress()
                methodPseudonameProfession()
//                if mainkValue < preferkValue { methodCommonationHardAddress() }
            }
            if identificators.contains("Address") && identificators.contains("Salary") {
                methodPseudonameAddress()
                methodCommonationLiteAddress()
                methodPseudonameSalary()
//                if mainkValue < preferkValue { methodCommonationHardAddress() }
            }
            if identificators.contains("Salary") && identificators.contains("Profession") {
                methodPseudonameSalary()
//                if mainkValue < preferkValue { methodPseudonameProfession() }
            }
        }
    }
    private func methodCommonationHardAddress() {
        print("Start methodCommonationHardAddress")
        
        var bourIndex = 0
        var bour = ["Юг", "Восток", "Центр", "Запад", "Север"]
        var ratio = csvManager.data["Address"]!.count / 5
        var maxPeople = ratio
        
        for rowIndex in 0..<csvManager.data["Address"]!.count {
            if rowIndex == maxPeople {
                maxPeople += ratio
                bourIndex += 1
            }
            
            csvManager.data["Address"]![rowIndex] = "\(bour[bourIndex])"
        }
    }
    private func methodPseudonameAddress() {
        print("Start methodPseudonameAddress")
        
        for rowIndex in 0..<self.csvManager.data["Address"]!.count {
            let item = csvManager.data["Address"]![rowIndex]
            let splitAddr = item.split(separator: " ")
            var name = ""
            for part in splitAddr {
                if Int(String(part.first!)) == nil && !part.first!.isLowercase {
                    name = String(part)
                    break
                }
            }
            csvManager.data["Address"]![rowIndex] = name
        }
    }
    private func methodCommonationLiteAddress() {
        print("Start methodCommonationLiteAddress")
        var bourIndex = 1
        var currBourIndex = 0
        let maxAddressBoud = 20
        
        var bourAddress = [String: Int]()
        for rowIndex in 0..<self.csvManager.data["Address"]!.count {
            if currBourIndex == maxAddressBoud {
                currBourIndex = 0
                bourIndex += 1
            }
            
            var item = self.csvManager.data["Address"]![rowIndex]
            if bourAddress[item] == nil {
                bourAddress[item] = bourIndex
                currBourIndex += 1
            }
            
            
            self.csvManager.data["Address"]![rowIndex] = "Район \(bourAddress[item]!)"
        }
    }
    
    private func methodPseudonameSalary() {
        print("Start methodPseudonameSalary")
        for rowIndex in 0..<self.csvManager.data["Salary"]!.count {
            var salary = self.csvManager.data["Salary"]![rowIndex]
            self.csvManager.data["Salary"]![rowIndex] = salarySector(for: salary)
        }
    }
    
    private func methodPseudonameProfession() {
//        guard let _ = self.csvManager.data[attr] else { fatalError("attr hasn't in csvManager") }
        print("Start methodPseudonameProfession")
        for rowIndex in 0..<self.csvManager.data["Profession"]!.count {
            let prof = self.csvManager.data["Profession"]![rowIndex]
            self.csvManager.data["Profession"]![rowIndex] = professionSector(for: prof)
        }
        
    }
    
    private func methodMask(for attr: String) {
//        guard let _ = self.csvManager.data[attr] else { fatalError("attr hasn't in csvManager") }
        print("Start methodMask for \(attr)")
        if attr == "Phone" {
            for (index, item) in self.csvManager.data[attr]!.enumerated() {
                var code = ""
                for char in item.dropFirst(2) {
                    if code.count == 3 { break}
                    code.append(char)
                }
                self.csvManager.data[attr]![index] = "\(code)"
            }
        }
    }
    
    private func methodDeleteAttribute(for attr: String) {
//        guard let _ = self.csvManager.data[attr] else { fatalError("attr hasn't in csvManager") }
        print("Start methodDeleteAttribute for \(attr)")
        self.csvManager.deleteData(forKey: attr)
        
    }
    
    
    private func readData() {
        self.csvManager.readData()
    }
    
    private func writeData(row: [String]) {
        do { try self.csvManager.writeData(row: row) }
            catch(let error) { fatalError(error.localizedDescription) }
        
    }
}

var identificators = ["Address", "Salary"]
let kanon = Kanonimity(csvManager: manager, kValue: 10, identificators: identificators)
kanon.anonimize()
