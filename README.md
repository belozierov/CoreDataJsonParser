# CoreDataJsonParser
JSON to Core Data parser

# Example

#### `JSON`

```json
{
	"countries": [
		{
			"id": 111,
			"name": "France",
			"details": {
				"capital": "Paris",
				"lang": "French"
			},
			"cities": {
					"id": 234,
					"name": "Paris",
					"population": 2243833
			}
        	},
        	{
			"id": 345,
			"name": "Germany",
			"details": {
				"capital": "Berlin",
				"lang": "German"
			},
			"cities": [
				{
					"id": 32,
					"name": "Berlin",
					"population": 3562166
				},
				{
					"id": 35,
					"name": "Munich",
					"population": 1424604
				}
			]
        }
    ]
}
```

#### `Model`

```swift

import CoreData

class Country: NSManagedObject {
    
    @NSManaged var id: Int16
    @NSManaged var name: String?
    @NSManaged var capital: String?
    @NSManaged var language: String?
    @NSManaged var cities: NSSet?
    
    override func manualSetValue(map: JsonMap) {
        self        <- map["details"]
        language    <- map["lang"]
    }
    
}

class City: NSManagedObject {
    
    @NSManaged var id: Int32
    @NSManaged var name: String?
    @NSManaged var population: String?
    @NSManaged var country: Country?
    
    override func manualSetValue(map: JsonMap) {
        population <- map["population"]?.transformed(roundedPopulation)
    }
    
    private func roundedPopulation(map: JsonWrapper) -> Double? {
        guard let population = map.int else { return nil }
        return Double(population / 10_000) / 100
        
    }
    
}
```
#### `Parsing`

```swift
let context: NSManagedObjectContext = SomeContext
let any: Any = SomeAny

let countries = json(any).array?.map { Country(context: context).parsed($0) }

```
