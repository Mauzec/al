import SwiftUI
import CSV

class Kanonimity {
    @Binding private var csvManager: CSVFileManager?
    private var identificators: Set<String>
    private var preferkValue: Int
    public var top5 = [Int]()
    public var k = 0
    public var uniqueRowCount: Int = 0
    
    public init(csvManager: Binding<CSVFileManager?>, kValue: Int, identificators: [String]) {
        _csvManager = csvManager
        self.preferkValue = kValue
        self.identificators = Set(identificators)
    }
    
    public func anonimize() {
        let startTime = DispatchTime.now()
        self.readData()
        chooseAndDoMethods()
        top5 = kValues()
        let endTime = DispatchTime.now()
        let nanosecs = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        let secs = Double(nanosecs) / 1_000_000_000
        print("Execution time: \(secs) sec")
    }
    
    private func calck(gropsCount: inout [[String]: Int], idents: [String], minValue: inout [Int], index: Int, writing: Bool = false, isCountUnique: Bool = false) {
        for rowIndex in 1..<csvManager!.data["Phone"]!.count {
            var row = [String]()
            row.append(csvManager!.data["Phone"]![rowIndex])
            for ident in idents {
                row.append(csvManager!.data[ident]![rowIndex])
            }
            if writing { writeData(row: row, closing: rowIndex != csvManager!.data["Phone"]!.count - 1 ? false : true) }
            row.remove(at: 0)
        
            if let count = gropsCount[row] {
                gropsCount[row] = count + 1
            } else { gropsCount[row] = 1}
        }
        for (value, count) in gropsCount {
            if isCountUnique { print(value) }
            if count < minValue[index] {
                minValue[index] = count
            }
        }
        minValue[index] = Int(Double(minValue[index] * gropsCount.count) / Double(csvManager!.data["Phone"]!.count) * 100.0)
        
        if isCountUnique { uniqueRowCount = gropsCount.count }
    }
    private func kValues() -> [Int] {
        var gropsCount = [ [String]: Int ]()
        var minValue = [Int]()
        for _ in 0..<4 {
            minValue.append(Int.max)
        }
        
        writeData(row: ["Phone", "Address", "Profession", "Salary"])
        
        var row = [String]()
        row.append(csvManager!.data["Phone"]![0])
        row.append(csvManager!.data["Address"]![0])
        row.append(csvManager!.data["Profession"]![0])
        row.append(csvManager!.data["Salary"]![0])
        
        writeData(row: row)
        row.remove(at: 0)
        
        var tmp = [""]
        
        let addr = identificators.contains("Address")
        let prof = identificators.contains("Profession")
        let sal = identificators.contains("Salary")
        
        
        gropsCount = [[String]: Int]()
        gropsCount[row] = 1
        calck(gropsCount: &gropsCount, idents: ["Address", "Profession", "Salary"], minValue: &minValue, index: 0, writing: true, isCountUnique: addr && prof && sal)
        
        gropsCount = [[String]: Int]()
        tmp = row
        tmp.remove(at: 2)
        gropsCount[tmp] = 1
        calck(gropsCount: &gropsCount, idents: ["Address", "Profession"], minValue: &minValue, index: 1, isCountUnique: addr && prof && identificators.count == 2)
        
        gropsCount = [[String]: Int]()
        tmp = row
        tmp.remove(at: 1)
        gropsCount[tmp] = 1
        calck(gropsCount: &gropsCount, idents: ["Address", "Salary"], minValue: &minValue, index: 2, isCountUnique: addr && sal && identificators.count == 2)
        
        gropsCount = [[String]: Int]()
        tmp = row
        tmp.remove(at: 0)
        gropsCount[tmp] = 1
        calck(gropsCount: &gropsCount, idents: ["Profession", "Salary"], minValue: &minValue, index: 3, isCountUnique: prof && sal && identificators.count == 2)
        
        
        var top5Values = [Int]()
        minValue.sort()
        var accepted = Set<Int>()
        for index in 0..<minValue.count {
            if minValue[index] != Int.max && !accepted.contains(minValue[index]) {
                top5Values.append((minValue[index]))
                accepted.insert(minValue[index])
            }
        }
        
        return top5Values
        
    }
    
    public var mainkValue: Int {
        get {
            var gropsCount = [[String] : Int]()
            var minValue = Int.max
            
            for rowIndex in 0..<self.csvManager!.data["Phone"]!.count {
                var row = [String]()
                for ident in self.identificators {
                    if let _ = self.csvManager!.data[ident] {
                        row.append(self.csvManager!.data[ident]![rowIndex])
                    }
                }
                if let _ = gropsCount[row] {
                    gropsCount[row] = gropsCount[row]! + 1
                } else {
                    gropsCount[row] = 1
                }
            }
            
            for (_, count) in gropsCount {
                if count < minValue { minValue = count }
            }
            
            if minValue == 1 {
                let fm = FileManager.default
                let outPath = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].standardizedFileURL.appendingPathComponent("unique-rows.csv", conformingTo: .database).standardizedFileURL.path()
                
                guard let outStream = OutputStream(toFileAtPath: outPath, append: false) else {
                    /// unknowed error: probably because of the filemanager
                    fatalError("Creating OutputStream with new csv path has cause an unknowed error")
                }
                let uniquecsv = try! CSVWriter(stream: outStream)
                
                for (value, _) in gropsCount {
                    try! uniquecsv.write(row: value)
                }
                uniquecsv.stream.close()
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
        let salary: Int = Int(salary)!
        if (salary < 50000) { return "0..<50" }
        if (salary >= 50000 && salary < 150000) { return "50..<150" }
        return "150..."
    }
    
    private func chooseAndDoMethods() {
        methodDeleteAttribute(for: "Full Name")
        methodMask(for: "Phone")
        
        if identificators.count == 3 {
            methodPseudonameProfession()
            methodPseudonameSalary()
            methodPseudonameAddress()
            methodCommonationLiteAddress()
            
            k = mainkValue
            if k < preferkValue { methodCommonationHardAddress(); k = mainkValue }
        }
        else if identificators.count == 2 {
            if identificators.contains("Address") && identificators.contains("Profession") {
                methodPseudonameProfession()
                
                methodPseudonameAddress()
                methodCommonationLiteAddress()
                
                k = mainkValue
                if k < preferkValue { methodCommonationHardAddress(); k = mainkValue }
            }
            if identificators.contains("Address") && identificators.contains("Salary") {

                methodPseudonameSalary()
                
                methodPseudonameAddress()
                methodCommonationLiteAddress()
                k = mainkValue
                if k < preferkValue { methodCommonationHardAddress(); k = mainkValue }
            }
            if identificators.contains("Salary") && identificators.contains("Profession") {
                methodPseudonameSalary()
                k = mainkValue
                if k < preferkValue { methodPseudonameProfession(); k = mainkValue }
            }
        }
        else if identificators.count == 0 || identificators.count == 1 {
            identificators = Set(arrayLiteral: "Address", "Profession", "Salary")
            k = mainkValue
        }
    }
    
    private func methodCommonationHardAddress() {
        print("Start methodCommonationHardAddress")
        
        var bourIndex = 0
        let bour = ["Юг", "Восток", "Центр", "Запад", "Север"]
        let ratio = csvManager!.data["Address"]!.count / 5
        var maxPeople = ratio
        
        for rowIndex in 0..<csvManager!.data["Address"]!.count {
            if rowIndex == maxPeople {
                maxPeople += ratio
                bourIndex += 1
            }
            
            csvManager!.data["Address"]![rowIndex] = "\(bour[bourIndex])"
        }
    }
    
    private func changeStreet(data: inout [String: [String]], index: Int) {
        var name = ""
        for part in data["Address"]![index].split(separator: " ") {
            let p = String(part)
            if Int(String(p.first!)) == nil && !p.first!.isLowercase {
                name = p
                break
            }
        }
        data["Address"]![index] = name
    }
    private func methodPseudonameAddress() {
        print("Start methodPseudonameAddress")
        
        let count = csvManager!.data["Address"]!.count
        for rowIndex in 0..<count {
            changeStreet(data: &csvManager!.data, index: rowIndex)
        }
    }
    
    private func methodCommonationLiteAddress() {
        print("Start methodCommonationLiteAddress")
        var bourIndex = 1
        var currBourIndex = 0
        let maxAddressBoud = 20
        
        var bourAddress = [String: Int]()
        for rowIndex in 0..<self.csvManager!.data["Address"]!.count {
            if currBourIndex == maxAddressBoud {
                currBourIndex = 0
                bourIndex += 1
            }
            
            let item = self.csvManager!.data["Address"]![rowIndex]
            if bourAddress[item] == nil {
                bourAddress[item] = bourIndex
                currBourIndex += 1
            }
            
            self.csvManager!.data["Address"]![rowIndex] = "Район \(bourAddress[item]!)"
        }
    }
    
    private func methodPseudonameSalary() {
        print("Start methodPseudonameSalary")
        for rowIndex in 0..<self.csvManager!.data["Salary"]!.count {
            let salary = self.csvManager!.data["Salary"]![rowIndex]
            self.csvManager!.data["Salary"]![rowIndex] = salarySector(for: salary)
        }
    }
    
    private func methodPseudonameProfession() {
//        guard let _ = self.csvManager.data[attr] else { fatalError("attr hasn't in csvManager") }
        print("Start methodPseudonameProfession")
        for rowIndex in 0..<self.csvManager!.data["Profession"]!.count {
            let prof = self.csvManager!.data["Profession"]![rowIndex]
            self.csvManager!.data["Profession"]![rowIndex] = professionSector(for: prof)
        }
        
    }
    
    private let Tele2 = Set(arrayLiteral: "900", "901", "996", "994", "992", "991", "952", "953", "951", "950", "904", "902")
    private let MTS =   Set(arrayLiteral: "911", "958", "981", "986", "989")
    private let Megafon=Set(arrayLiteral: "999", "959", "939", "937", "933", "932", "931", "930", "929", "924", "923", "921")
    private let Beeline=Set(arrayLiteral: "903", "969", "968", "967", "966", "965", "964", "963",
                            "962", "961", "960", "909", "906", "905")
    private func methodMask(for attr: String) {
        print("Start methodMask for \(attr)")
        if attr == "Phone" {
            for (index, item) in self.csvManager!.data[attr]!.enumerated() {
                var code = ""
                for char in item.dropFirst(2) {
                    if code.count == 3 { break}
                    code.append(char)
                }
                var provider = ""
                if Tele2.contains(code) { provider = "Tele2" }
                if MTS.contains(code) { provider = "MTS" }
                if Megafon.contains(code) { provider = "Megafon" }
                if Beeline.contains(code) { provider = "Beeline" }
                self.csvManager!.data[attr]![index] = provider
            }
        }
    }
    
    private func methodDeleteAttribute(for attr: String) {
        print("Start methodDeleteAttribute for \(attr)")
        self.csvManager!.deleteData(forKey: attr)
        
    }
    
    private func readData() {
        self.csvManager!.readData()
    }
    private func writeData(row: [String], closing: Bool = false) {
        do { try self.csvManager!.writeData(row: row, closing: closing) }
            catch(let error) { fatalError(error.localizedDescription) }
        
    }
}
