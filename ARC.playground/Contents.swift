import UIKit

// ARC in Action
class Person1 {
    let name: String
    init(name: String) {
        self.name = name
        print("\(name) is being initialized")
    }
    deinit {
        print("\(name) is being deallocated")
    }
}

var reference1: Person1?
var reference2: Person1?
var reference3: Person1?

reference1 = Person1(name: "Himanshu")
reference2 = reference1
reference3 = reference1

reference1 = nil
reference2  = nil

// ARC does not deallocate the person until the third and final strong reference is broken.
reference3 = nil
// deallocated.

//------------------------------------------------------------------------------------------------//
// Strong referencing cycle between class instances

class Person {
    let name: String
    
    init(name: String) {
        self.name = name
    }
    var apartment: Apartment?
    deinit {
        print("\(name) is being deinitialized")
    }
}

class Apartment {
    let unit: String
    init(unit: String) {
        self.unit = unit
    }
    var tanent: Person?
    deinit {
        print("\(unit) is being deinitialized")
    }
}

var himanshu1: Person?
var unit41: Apartment?

himanshu1 = Person(name: "Himanshu Rajput")
unit41 = Apartment(unit: "4A")

himanshu1!.apartment = unit41
unit41!.tanent = himanshu1

himanshu1 = nil
unit41 = nil
// instances between person and aparment is still there

//------------------------------------------------------------------------------------------------//
// Resolving strong reference cycle between class instances

/*
 ARC automatically sets a weak reference to nil.
 Property observer aren't called when ARC sets a weak reference to nil.
 */

// Weak reference

class PersonWeak {
    let name: String
    
    init(name: String) {
        self.name = name
    }
    var apartment: ApartmentWeak?
    deinit {
        print("\(name) is being deinitialized")
    }
}

class ApartmentWeak {
    let unit: String
    init(unit: String) {
        self.unit = unit
    }
    weak var tanent: PersonWeak?
    deinit {
        print("\(unit) is being deinitialized")
    }
}

var himanshu: PersonWeak?
var unit4A: ApartmentWeak?

himanshu = PersonWeak(name: "Himanshu Rajput")
unit4A = ApartmentWeak(unit: "4A")

himanshu!.apartment = unit4A
unit4A!.tanent = himanshu

himanshu = nil
unit4A = nil

// Unowned References

class Customer {
    let name: String
    var card: CreditCard?
    init(name: String) {
        self.name = name
    }
    deinit {
        print("customer \(name) is being deinitialized")
    }
}

class CreditCard {
    let number: UInt64
    unowned let customer: Customer
    init(number: UInt64, customer: Customer) {
        self.number = number
        self.customer = customer
    }
    deinit {
        print("Card #\(number) is being deallocated")
    }
}

var himanshuCustomer: Customer?
himanshuCustomer = Customer(name: "Himanshu Rajput")
himanshuCustomer!.card = CreditCard(number: 1234_5678_1234_1234, customer: himanshuCustomer!)

himanshuCustomer = nil


// Unowned optional reference

class Department {
    var name: String
    var courses: [Course]
    init(name: String) {
        self.name = name
        self.courses = []
    }
}

class Course {
    var name: String
    unowned var department: Department
    unowned var nextCourse: Course?
    init(name: String, department: Department) {
        self.name = name
        self.department = department
        self.nextCourse = nil
    }
}

let department = Department(name: "Math")
let intro = Course(name: "chapter 1", department: department)
let intermediate = Course(name: "chapter 2", department: department)
let advanced = Course(name: "chapter 3", department: department)

intro.nextCourse = intermediate
intermediate.nextCourse = advanced
department.courses = [intro, intermediate, advanced]

//

class Country {
    let name: String
    var capitalCity: City!
    init(name: String, capitalName: String) {
        self.name = name
        self.capitalCity = City(name: capitalName, country: self)
    }
}

class City {
    let name: String
    unowned let country: Country
    init(name: String, country: Country) {
        self.name = name
        self.country = country
    }
}

var country = Country(name: "India", capitalName: "Delhi")
print("\(country.name)'s capital city is called \(country.capitalCity.name)")

//------------------------------------------------------------------------------------------------//

// Strong reference cycles for closures

class HTMLElement {
    let name: String
    let text: String?
    
    //    lazy var asHTML: () -> String = {
    lazy var asHTML: () -> String = { [unowned self] in
        if let text = self.text {
            return "<\(self.name)>\(text)</\(self.name)>"
        } else {
            return "<\(self.name) />"
        }
    }
    
    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }
    
    deinit {
        print("\(name) is being deinitialized")
    }
}

let header = HTMLElement(name: "h1")
let defaultText = "some default text"
header.asHTML = {
    return "<\(header.name)>\(header.text ?? defaultText)</\(header.name)>"
}

print(header.asHTML())

var paragraph: HTMLElement? = HTMLElement(name: "p", text: "hello, world")
print(paragraph!.asHTML())

paragraph = nil

// Resolving strong reference cycle for closures

/*
 create a capture list before a closure's parameter list and return type if they are provided:
 */

/*
 lazy var someClosure = {
 [unowned self, weak delegate = self.delegate] (index: Int, stringToProcess: String) -> String in
 // closure body goes here
 }
 
 lazy var someClosure = {
 [unowned self, weak delegate = self.delegate] in
 // closure body goes here
 }
 
 */

// Weak and unowned References



