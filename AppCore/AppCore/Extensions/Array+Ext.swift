
import Foundation


public extension Array {
    
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    func shuffled() -> [Element] {
        var list = self 
        if list.isEmpty { return [] }
        
        guard list.count > 0 else { return [] }
        
        var results : [Array.Iterator.Element] = []
        var indexes = (0 ..< count).map { $0 }
        while indexes.count > 0 {
            let indexOfIndexes = Int(arc4random_uniform(UInt32(indexes.count)))
            let index = indexes[indexOfIndexes]
            results.append(list[index])
            indexes.remove(at: indexOfIndexes)
        }
        return results
    }
    
    public func take(_ amount: Int) -> [Element] {
        var list = self
        guard list.count > 1, amount <= list.count else { return [] }
        
        var temp : [Array.Iterator.Element] = []
        var count = amount
        
        while count > 0 {
            let index = Int(arc4random_uniform(UInt32(list.count - 1)))
            temp.append(list[index])
            list.remove(at: index)
            
            count -= 1
        }
        
        return temp
    }
}


public extension Array where Array.Iterator.Element: Hashable {
    //public typealias Element = Array.Iterator.Element
    
    public func uniqueElements() -> [Element] {
        let list = self
        if list.isEmpty { return [] }
        
        // Convert array into a set to get unique values.
        let uniques = Set<Element>(list)
        // Convert set back into an Array of Ints.
        let result = Array<Element>(uniques)
        return result
    }
    
    public func skipDuplicates() -> [Element] {
        
        var list = self 
        
        if list.isEmpty { return [] }
        
        //do not take duplicated words
        var tempList : [Array.Iterator.Element] = []
        var elementsRemoved : [Array.Iterator.Element] = []
        
        for word in list{
            if (tempList.contains(word)){
                //found the next of the duplicated word
                if let index = tempList.index(of: word){
                    tempList.remove(at: index)
                    list.remove(at: index)
                }
                elementsRemoved.append(word)
            }else{
                
                if elementsRemoved.contains(word){ 
                    //do not add any word that is been removed
                }else{
                    tempList.append(word)
                }
            }
        }
        return tempList
    }
    
    public func frequencyCount() -> [Element: Int] {
        return reduce([:]) { (accu: [Element: Int], element) in
            var accu = accu
            accu[element] = accu[element]?.advanced(by: 1) ?? 1
            return accu
        }
    }
    
    public func chooseOne () -> Element {
        
        let list: [Element] = self 
        let len = UInt32(list.count)
        let random = Int(arc4random_uniform(len))
        return list[random]
    }
    
    public func takeRandom(amount: Int) -> [Element] {
        var list = self 
        if list.isEmpty { return [] }
        
        guard list.count > 1, amount <= list.count else { return [] }
        
        var temp : [Array.Iterator.Element] = []
        var count = amount
        
        while count > 0 {
            let index = Int(arc4random_uniform(UInt32(list.count - 1)))
            temp.append(list[index])
            list.remove(at: index)
            
            count -= 1
        }
        
        return temp
    }
    
    public func randomise() -> [Element] {
        var list = self 
        if list.isEmpty { return [] }
        
        guard list.count > 0 else { return [] }
        
        var temp : [Array.Iterator.Element] = []
        
        while list.count > 0 {
            let index = Int(arc4random_uniform(UInt32(list.count - 1)))
            temp.append(list[index])
            list.remove(at: index)
        }
        
        return temp
    }
    
    public func makePairs () -> [Element] { 
        let list = self 
        if list.isEmpty { return [] }
        
        let temp = list + list
        return temp.randomise()
    }
    
    public func removeAllAfter(index: Int) -> [Element]{
        let list = self 
        if list.isEmpty { return [] }
        guard list.count > index else { return [] }
        
        var temp : [Array.Iterator.Element] = []
        for (ind,element) in list.enumerated(){
            if (ind <= index) {
                temp.append(element) 
            } 
        }
        return temp
    }
    
}

public extension Array where Element: Comparable {
    public func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}



