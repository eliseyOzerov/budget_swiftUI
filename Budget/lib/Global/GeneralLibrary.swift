//
//  GeneralLibrary.swift
//  Budget
//
//  Created by Elisey Ozerov on 26/02/2021.
//

import Foundation

func update(base: inout String, new: String) {
    // if user deleted a character, the second part is for when the
    // currency symbol is at the end
    if(new.count < base.count && !base.last!.isNumber) {
        // define regex to remove non-numeric characters
        let regex = try! NSRegularExpression(pattern: "[^0-9]")
        // get string representation of all numeric characters
        let string = regex.stringByReplacingMatches(in: new, range: NSMakeRange(0, new.count), withTemplate: "")
        // remove last character and create double from resulting value
        let double = (string[..<string.index(string.endIndex, offsetBy: -1)] as NSString).doubleValue / 100
        // makes sure that textfield value reformats, even if the underlying double doesn't change. if this isn't done, when value stays 0 for example (same as in the beginning), the textfield value doesn't reformat which enables user to delete currency symbol if it's placed at the end or add zero's after the currency symbol
        base = new
        base = double.toCurrencyString()
    } else {
        base = new
        base = new.toDouble().toCurrencyString()
    }
}
