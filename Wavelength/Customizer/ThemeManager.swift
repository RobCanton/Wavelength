//
//  ThemeManager.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-18.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

protocol ThemeDelegate:class {
    func didThemeUpdate()
}
class ThemeAttribute {
    let name:String
    
    init(name:String) {
        self.name = name
    }
}

class ThemeAttributeColor:ThemeAttribute {
    var color:UIColor
    init(name: String, color:UIColor) {
        self.color = color
        super.init(name: name)
    }
}

class ThemeAttributeValue:ThemeAttribute {
    var value:Int
    init(name: String, value:Int) {
        self.value = value
        super.init(name: name)
    }

    var percentageValue:CGFloat {
        get {
            return CGFloat(value) / 100.0
        }
    }
}

class ThemeAttributeBool:ThemeAttribute {
    var value:Bool
    init(name: String, value:Bool) {
        self.value = value
        super.init(name: name)
    }

}

class Theme {
    var name:String
    var background:ThemeAttributeColor
    var title:ThemeAttributeColor
    
    var subtitle:ThemeAttributeColor
    var button:ThemeAttributeColor
    var buttonBackground:ThemeAttributeColor
    var detailPrimary:ThemeAttributeColor
    var detailSecondary:ThemeAttributeColor
    
    
    var musicBarBackground:ThemeAttributeColor
    var musicBarButton:ThemeAttributeColor
    var musicBarColorAlpha:ThemeAttributeValue
    var musicBarBlurIntensity:ThemeAttributeValue
    
    var darkStatusBar:ThemeAttributeBool
    var darkKeyboard:ThemeAttributeBool
    
    private(set) var attributes: [ThemeAttribute]
    
    private(set) var musicBarAttributes:[ThemeAttribute]
    
    private(set) var miscAttributes:[ThemeAttribute]
    
    init(name: String, background: UIColor, title:UIColor, subtitle: UIColor, button:UIColor, buttonBackground:UIColor, detailPrimary:UIColor, detailSecondary:UIColor, musicBarBackground:UIColor, musicBarButton:UIColor, musicBarColorAlpha:Int, musicBarBlurIntensity:Int, darkStatusBar:Bool, darkKeyboard:Bool) {
        self.name = name
        self.background = ThemeAttributeColor(name: "Background", color: background)
        self.title = ThemeAttributeColor(name: "Title", color: title)
        self.subtitle = ThemeAttributeColor(name: "Subtitle", color: subtitle)
        self.button = ThemeAttributeColor(name: "Button", color: button)
        self.buttonBackground = ThemeAttributeColor(name: "Button Background", color: buttonBackground)
        self.detailPrimary = ThemeAttributeColor(name: "Detail Primary", color: detailPrimary)
        self.detailSecondary = ThemeAttributeColor(name: "Detail Secondary", color: detailSecondary)
        attributes = [
            self.background, self.title, self.subtitle, self.button, self.buttonBackground, self.detailPrimary, self.detailSecondary
        ]
        
        self.musicBarBackground = ThemeAttributeColor(name: "Music Bar Background", color: musicBarBackground)
        self.musicBarButton = ThemeAttributeColor(name: "Music Bar Button", color: musicBarButton)
        self.musicBarColorAlpha = ThemeAttributeValue(name: "Music Bar Color Alpha", value: musicBarColorAlpha)
        self.musicBarBlurIntensity = ThemeAttributeValue(name: "Music Bar Blur Intensity", value: musicBarBlurIntensity)
        
        musicBarAttributes = [
            self.musicBarBackground, self.musicBarButton, self.musicBarColorAlpha, self.musicBarBlurIntensity
        ]
        
        self.darkStatusBar = ThemeAttributeBool(name: "Dark Status Bar", value: darkStatusBar)
        self.darkKeyboard = ThemeAttributeBool(name: "Dark Keyboard", value: darkKeyboard)
        miscAttributes = [
            self.darkStatusBar, self.darkKeyboard
        ]
        
    }
    
    var copy:Theme {
        get {
            return Theme(name: self.name,
                         background: self.background.color,
                         title: self.title.color,
                         subtitle: self.subtitle.color,
                         button: self.button.color,
                         buttonBackground: self.buttonBackground.color,
                         detailPrimary: self.detailPrimary.color,
                         detailSecondary: self.detailSecondary.color,
                         musicBarBackground:self.musicBarBackground.color,
                         musicBarButton: self.musicBarButton.color,
                         musicBarColorAlpha:self.musicBarColorAlpha.value,
                         musicBarBlurIntensity:self.musicBarBlurIntensity.value,
                         darkStatusBar: self.darkStatusBar.value,
                         darkKeyboard:self.darkKeyboard.value)
        }
    }

}


class ThemeManager {
    static let didThemeUpdate = NSNotification.Name("didThemeUpdate")
    static private(set) var currentTheme = getDefaultTheme
    
    
    static private(set) var recentColors:[UIColor] = [
        .white, .black, .gray, .blue, UIColor(white: 0.4, alpha: 1.0), UIColor(white: 0.85, alpha: 1.0)
    ]
    
    static func addRecentColor(_ color:UIColor) {
        for i in 0..<recentColors.count {
            let existingColor = recentColors[i]
            if existingColor == color {
                recentColors.remove(at: i)
                break
            }
        }
        
        recentColors.insert(color, at: 0)
    }
    
    static var getDefaultTheme:Theme {
        get {
           return defaultThemes[0]
        }
    }

    static func setNewTheme(_ theme:Theme) {
        userConfig.currenttheme = theme.name
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        currentTheme = theme
        NotificationCenter.default.post(name: didThemeUpdate, object: nil)
    }
    
    static var customThemes:[Theme] = []
    
    static func addNewTheme(_ theme:Theme) -> Bool {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let themeEntity = ThemeEntity(context: context)
        themeEntity.name = theme.name
        themeEntity.backgroundColor = theme.background.color
        themeEntity.titleColor = theme.title.color
        themeEntity.subtitleColor = theme.subtitle.color
        themeEntity.buttonColor = theme.button.color
        themeEntity.buttonBackgroundColor = theme.buttonBackground.color
        themeEntity.detailPrimaryColor = theme.detailPrimary.color
        themeEntity.detailSecondaryColor = theme.detailSecondary.color
        themeEntity.musicBarBackgroundColor = theme.musicBarBackground.color
        themeEntity.musicBarButtonColor = theme.musicBarButton.color
        themeEntity.musicBarColorAlpha = Int16(theme.musicBarColorAlpha.value)
        themeEntity.musicBarBlurIntensity = Int16(theme.musicBarBlurIntensity.value)
        themeEntity.darkStatusBar = theme.darkStatusBar.value
        themeEntity.darkKeyboard = theme.darkKeyboard.value
        
        // Save the data to coredata
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        for existingTheme in defaultThemes {
            if theme.name == existingTheme.name {
                return false
            }
        }
        
        for existingTheme in customThemes {
            if theme.name == existingTheme.name {
                return false
            }
        }
        
        customThemes.append(theme)
        return true
    }
    
    static func updateTheme(_ theme:Theme) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        do {
            let entities:[ThemeEntity] = try context.fetch(ThemeEntity.fetchRequest())
            var entityToUpdate:ThemeEntity?
            for entity in entities {
                if let entityName = entity.name {
                    if entityName == theme.name {
                        entityToUpdate = entity
                        break
                    }
                }
            }
            
            if let entity = entityToUpdate {
                entity.name = theme.name
                entity.backgroundColor = theme.background.color
                entity.titleColor = theme.title.color
                entity.subtitleColor = theme.subtitle.color
                entity.buttonColor = theme.button.color
                entity.buttonBackgroundColor = theme.buttonBackground.color
                entity.detailPrimaryColor = theme.detailPrimary.color
                entity.detailSecondaryColor = theme.detailSecondary.color
                entity.musicBarBackgroundColor = theme.musicBarBackground.color
                entity.musicBarButtonColor = theme.musicBarButton.color
                entity.musicBarColorAlpha = Int16(theme.musicBarColorAlpha.value)
                entity.musicBarBlurIntensity = Int16(theme.musicBarBlurIntensity.value)
                entity.darkStatusBar = theme.darkStatusBar.value
                entity.darkKeyboard = theme.darkKeyboard.value
            }
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
        } catch {
            print("Error with request")
        }
        
        if let currentTheme = userConfig.currenttheme {
            if currentTheme == theme.name {
                setNewTheme(theme)
            }
        }
        

    }
    
    static func deleteTheme(_ theme:Theme) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let entities:[ThemeEntity] = try context.fetch(ThemeEntity.fetchRequest())
            var entityToDelete:ThemeEntity?
            for entity in entities {
                if let entityName = entity.name {
                    if entityName == theme.name {
                        entityToDelete = entity
                        break
                    }
                }
            }
            
            if let entity = entityToDelete {
                context.delete(entity)
            }
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
        } catch {
            print("Error with request")
        }
    }
    
    static var defaultThemes:[Theme] {
        get {
            return [
                Theme(name: "Apple Music",
                      background: .white,
                      title: .black,
                      subtitle: .gray,
                      button: UIColor(red: 1.0, green: 45/255, blue: 85/255, alpha: 1.0),
                      buttonBackground: UIColor(white: 0.95, alpha: 1.0),
                      detailPrimary: UIColor(white: 0.4, alpha: 1.0),
                      detailSecondary: UIColor(white: 0.85, alpha: 1.0),
                      musicBarBackground:.white,
                      musicBarButton:.black,
                      musicBarColorAlpha:75,
                      musicBarBlurIntensity:50,
                      darkStatusBar: true,
                      darkKeyboard: false),
                Theme(name: "Apple Music Blue",
                      background: .white,
                      title: .black,
                      subtitle: .gray,
                      button: UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1.0),
                      buttonBackground: UIColor(white: 0.95, alpha: 1.0),
                      detailPrimary: UIColor(white: 0.4, alpha: 1.0),
                      detailSecondary: UIColor(white: 0.85, alpha: 1.0),
                      musicBarBackground:.white,
                      musicBarButton:.black,
                      musicBarColorAlpha:75,
                      musicBarBlurIntensity:50,
                      darkStatusBar: true,
                      darkKeyboard: false),
                Theme(name: "Dark",
                      background: .black,
                      title: .white,
                      subtitle: .lightGray,
                      button: .blue,
                      buttonBackground: UIColor(white: 0.95, alpha: 1.0),
                      detailPrimary: UIColor(white: 0.4, alpha: 1.0),
                      detailSecondary: UIColor(white: 0.85, alpha: 1.0),
                      musicBarBackground:.black,
                      musicBarButton:.white,
                      musicBarColorAlpha:75,
                      musicBarBlurIntensity:50,
                      darkStatusBar: false,
                      darkKeyboard: true)
            ]
        }
    }
    
    static var customThemeEntities: [ThemeEntity] = [] {
        didSet {
            var themes = [Theme]()
            for entity in customThemeEntities {
                if let name = entity.name,
                    let backgroundColor = entity.backgroundColor as? UIColor,
                    let titleColor = entity.titleColor as? UIColor,
                    let subtitleColor = entity.subtitleColor as? UIColor,
                    let buttonColor = entity.buttonColor as? UIColor,
                    let buttonBackgroundColor = entity.buttonBackgroundColor as? UIColor,
                    let detailPrimaryColor = entity.detailPrimaryColor as? UIColor,
                    let detailSecondaryColor = entity.detailSecondaryColor as? UIColor,
                    let musicBarBackgroundColor = entity.musicBarBackgroundColor as? UIColor,
                    let musicBarButtonColor = entity.musicBarButtonColor as? UIColor,
                    let musicBarColorAlpha = entity.musicBarColorAlpha as? Int16,
                    let musicBarBlurIntensity = entity.musicBarBlurIntensity as? Int16,
                    let darkStatusBar = entity.darkStatusBar as? Bool,
                    let darkKeyboard = entity.darkKeyboard as? Bool{
                    
                    
                    let theme = Theme(name: name,
                          background: backgroundColor,
                          title: titleColor,
                          subtitle: subtitleColor,
                          button: buttonColor,
                          buttonBackground: buttonBackgroundColor,
                          detailPrimary: detailPrimaryColor,
                          detailSecondary: detailSecondaryColor,
                          musicBarBackground: musicBarBackgroundColor,
                          musicBarButton: musicBarButtonColor,
                          musicBarColorAlpha: Int(musicBarColorAlpha),
                          musicBarBlurIntensity: Int(musicBarBlurIntensity),
                          darkStatusBar: darkStatusBar,
                          darkKeyboard: darkKeyboard)
                    
                    themes.append(theme)
                }
            }
            customThemes = themes
        }
    }
    
    static func fetchCustomThemes() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            customThemeEntities = try context.fetch(ThemeEntity.fetchRequest())
            
        }
        catch {
            print("Fetching Failed")
        }
    }
}

var currentTheme:Theme {
    get {
        return ThemeManager.currentTheme
    }
}

var themeKeyboardType:UIKeyboardAppearance {
    get {
        return currentTheme.darkKeyboard.value ? .dark : .light
    }
}

var themeBarStyle: UIBarStyle {
    get {
        return currentTheme.darkStatusBar.value ? .default : .black
    }
}

class ThemeFactory {
    
    
}
