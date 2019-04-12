//
//  GameScene.swift
//  ShootIt
//
//  Created by etudiant on 08/04/2019.
//  Copyright © 2019 etudiant. All rights reserved.
//

import SpriteKit
import Foundation

//Les instructions ci-dessous sont nécessaires au bon fonctionnement de l'utilisation de Random
//On peut maintenant générer des valeurs de type Double de façon alétoires
//Sans ses instructions on obtient des erreurs

extension Range where Bound == Int {
    var random: Int {
        return lowerBound + numericCast(arc4random_uniform(numericCast(count)))
    }
    func random(_ n: Int) -> [Int] {
        return (0..<n).map { _ in random }
    }
}
extension ClosedRange where Bound == Int {
    var random: Int {
        return lowerBound + numericCast(arc4random_uniform(numericCast(count)))
    }
    func random(_ n: Int) -> [Int] {
        return (0..<n).map { _ in random }
    }
}

extension Double {
    var absoluteValue: Double {
        if self > 0.0 {
            return self
        }
        else {
            return -1 * self
        }
    }
}

//Les instructions ci-dessous permmet de "suffle" un array
//Shuffle est une méthode permettant de réorganiser les éléments d'un array

extension Array
{
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<10
        {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
}




class GameScene: SKScene {
    
    
    
    
    
    
    
    var slots = [WhackSlot]()   //Un array nous permettant de stocker toutes nos fenêtres
    var gameScore: SKLabelNode! //Label du score
    
    var popupTime = 0.85    //Temps d'affichage des objets
    
    var score = 0 {         //Variable qui contiendra notre score
        didSet {
            gameScore.text = "\(score)"
        }
    }
    
    var numRounds = 0   //numRounds correspond au nombre d'entitées touchées, que ce soit des les bons ou les mauvais, plus bas on définira le nombre maximum d'entitées, c'est lui qui controllera si le jeu est terminé ou non


    override func didMove(to view: SKView) {
        
        //On place ici l'arrière plan de notre jeu
        let background = SKSpriteNode(imageNamed: "FINAL_Building_NoWindows")   //SKSpriteNote est un élémen graphique qui peut être initialisé à partir d'une image ou d'une couleur unie. imageNamed initialise une image-objet texturée à l'aide d'un fichier image
        background.position = CGPoint(x: 0, y: 0)   //On définie les coordonées de l'arrière plan
        background.blendMode = .replace             //blendeMode est une propriété qui décrit comment tous les "SpriteKit nodes" doivent être dessinés à l'écran. La valeur par défaut est ".alpha" qui signifie que l'image doit être dessiné pour que la transparence alpha soit respectée, on utilise ".replace" pour ignorer l'alpha dans la texture. Plus d'infos : https://www.hackingwithswift.com/example-code/games/how-to-made-an-skspritenode-render-faster-using-blendmode
        background.zPosition = -1
        addChild(background)       //On ajoute l'arrière plan à notre ViewController, ici GameViewController
        
        gameScore = SKLabelNode(fontNamed:"Chalkduster")    //On définit une police pour le texte
        gameScore.text = "Score 0"                          //On définit notre texte
        gameScore.position = CGPoint(x: -320, y: 580)       //On positionne le texte
        gameScore.horizontalAlignmentMode = .left           //On définit l'alignement horizontale
        gameScore.fontSize = 48                             //On définit la taille du texte
        addChild(gameScore)
        
        
        //Les boucles ici correspondent à la création et à l'emplacement des fenêtres
        //On aura ici 5 lignes et 4 colonnes de fenêtres
        //L'appel de la fonction createSlot permet de créer les fenêtres
        //CGPoint est une structure qui contient un point dans un système de coordonnées à deux dimensions 
        for i in 0..<4 { createSlot(at: CGPoint(x: -225 + (i * 150), y: 400))}
        for i in 0..<4 { createSlot(at: CGPoint(x: -225 + (i * 150), y: 250))}
        for i in 0..<4 { createSlot(at: CGPoint(x: -225 + (i * 150), y: 100))}
        for i in 0..<4 { createSlot(at: CGPoint(x: -225 + (i * 150), y: -120))}
        for i in 0..<4 { createSlot(at: CGPoint(x: -225 + (i * 150), y: -300))}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self]
            in self?.createEnemy()
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }
            whackSlot.hit()
            
            if node.name == "charFriend" {
                //Touche la mauvaise cible
                score -= 5
            } else if node.name == "charEnemy"{
                //Touche la bonne cible
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                score += 1
            }
        }
        
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    
    
    func createEnemy() {
        numRounds += 1
        
        if numRounds >= 15 {
            for slot in slots {
                slot.hide()
            }
            
            let button = SKSpriteNode(imageNamed: "bouton-play")
            let gameOver = SKSpriteNode(imageNamed: "")
            gameOver.position = CGPoint(x: 128, y: 128)
            gameOver.zPosition = 1
            button.position = CGPoint(x: -256, y: 128)
            addChild(gameOver)
            addChild(button)
            
            

            
            
            return
            
        }

        
        popupTime *= 1.085
        
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        
        if (0...12).random > 4 {slots[1].show(hideTime: popupTime)}
        if (0...12).random > 8 {slots[2].show(hideTime: popupTime)}
        if (0...12).random > 10 {slots[3].show(hideTime: popupTime)}
        if (0...12).random > 11 {slots[4].show(hideTime: popupTime)}
        if (0...12).random > 50 {slots[5].show(hideTime: popupTime)}
 
        
        /*
        if Int(arc4random()) * (12) > 1 {slots[1].show(hideTime: popupTime)}
        if Int(arc4random()) * (12) > 4 {slots[2].show(hideTime: popupTime)}
        if Int(arc4random()) * (12) > 7 {slots[3].show(hideTime: popupTime)}
        if Int(arc4random()) * (12) > 10 {slots[4].show(hideTime: popupTime)}
        */
        
        let minDelay = popupTime / 2.5
        let maxDelay = popupTime * 2
        let delay = Double(arc4random_uniform(UInt32(minDelay + maxDelay)))
        //let delay = Double(arc4random()) * (minDelay - maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
    }
}

