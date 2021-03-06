//
//  QuestionCollectionViewController.swift
//  MQF
//
//  Created by Christian Brechbuhl on 5/27/19.


import UIKit
import UICircularProgressRing

private let reuseIdentifier = "answerCell"

/// View that controls taking the quiz
class QuestionCollectionViewController: UICollectionViewController {
    /// Currently active question
    var activeQuestion:QKQuestion?
    /// Current Quiz Session
    var quizSession:QKSession = QKSession.default
    /// Test mode (Study or Test)
    var mode:QuizMode = .Study
    /// Submitted Answer
    var answerSubmitted = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView : UIImageView = {
            let iv = UIImageView()
            iv.image = UIImage(named:"pentagon")
            iv.contentMode = .scaleAspectFill
            return iv
        }()
        self.collectionView?.backgroundView = imageView
        self.startQuiz(self)
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    /// Dismisses quiz view
    @IBAction func homeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Goes to next question
    @IBAction func nextButton(_ sender: Any) {
        self.nextQuestion()
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.activeQuestion?.responses.count ?? 0
    }
    
    /// Sets the data on the cell for each row in the table
    /// - Returns:`UICollectionViewCell` for the given index
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! QuestionAnswerCollectionViewCell
        if(self.activeQuestion != nil){
            cell.answerLabel.text = self.activeQuestion?.responses[indexPath.row]
            cell.answerIDlabel.text = self.generateAnswerIdForIndexPath(indexPath: indexPath)
            cell.tag = indexPath.row
            cell.setColor(answerColor: .Normal)
        }else{
            cell.answerLabel.text = "Response not available"
        }
        
        cell.contentView.layer.cornerRadius = 20.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.backgroundColor = UIColor.white
        cell.contentView.layer.masksToBounds = true;
        
        return cell
    }
    
    /// Creates supplimentary views (header, footer)
    /// In this case the header includes both the current score and the actually questions
    /// The footer includes the reference
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if(kind == UICollectionView.elementKindSectionHeader){
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "questionHeader", for: indexPath) as! QuestionheaderCollectionReusableView
            if(self.mode == .Test){
                view.scoreRing.alpha = 0.5
                view.scoreStackView.isHidden = true
                view.scoreRing.style = .ontop
            }else{
                view.updateScore(session: quizSession)
            }
            if((activeQuestion) != nil){
                view.questionLabel.text = activeQuestion?.question
                view.updateProgress(session: quizSession, question: activeQuestion!)
            }else{
                view.questionLabel.text = "Please select a MQF"
            }
            
            
            return view
        }else{
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "questionFooter", for: indexPath) as! QuestionFooterCollectionReusableView
            if(activeQuestion != nil){
                view.refOutlet.text = "Reference: \(activeQuestion!.reference ?? "")"
            }
            return view
        }
    }
    
    
    // MARK: UICollectionViewDelegate
    /// When an answer row is selected, submit it
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.submitAnswer(indexPath: indexPath)
    }
    
    /// sets size of each item
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(self.collectionView.frame.size.width >= 400){
            return CGSize(width: self.collectionView.frame.size.width * 0.60, height: 55)
        }
        return CGSize(width: self.collectionView.frame.size.width - (self.collectionView.frame.size.width * 0.05), height: 55)
    }
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
    
    //TODO: Determine if still used
    @IBAction func startQuiz(_ sender: Any) {
        do {
            try quizSession.start()
        } catch {
            let alert = UIAlertController(title: "Error", message: "We couldn't load that MQF, please try a different one and let us know at AirmenCoders@us.af.mil", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                  switch action.style{
                  case .default:
                        print("default")

                  case .cancel:
                        print("cancel")

                  case .destructive:
                        print("destructive")


            }}))
            self.present(alert, animated: true, completion: nil)
      
          //  fatalError("Quiz started without quiz set on the session")
        }
        
        if let question = quizSession.nextQuestion() {
            // SHOW THE QUESTION VIEW HERE
            self.activeQuestion = question
            self.collectionView.reloadData()
        }
    }
    
    /// Moves quiz to next question
    func nextQuestion(){
        print("next")
        
        if let question = quizSession.nextQuestion(after: self.activeQuestion) {
            // SHOW THE QUESTION VIEW HERE
            self.activeQuestion = question
            self.answerSubmitted = -1
            self.collectionView.reloadData()
        }else{
            let loop = MQFDefaults().object(forKey: MQFDefaults.studyLoop) as? Bool ?? true
            if( self.mode == .Study && loop){
               self.activeQuestion = self.quizSession.restartSessionNextQuestion()
                self.answerSubmitted = -1
                self.collectionView.reloadData()
            }else{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nc = storyBoard.instantiateViewController(withIdentifier: "ResultsNC") as! UINavigationController
            let vc = nc.topViewController as! ResultsTableViewController
            vc.session = quizSession
            
            let parent = self.presentingViewController!
            
            parent.dismiss(animated: true, completion: {
                
                parent.present(nc, animated: true, completion: nil)
            })
            
            }
        }
    }
    
    /// Submits an answer to the current quiz session or moves to the next question if already submitted
    /// - Parameters:
    ///     - indexPath: `indexPath` of selected answer
    func submitAnswer(indexPath:IndexPath){
        let row = indexPath.row
        if(self.answerSubmitted != row){ // Checks to see if the user clicked the answer once already, if first click process, if second move to next question
            if(self.mode == .Test || (self.mode == .Study && self.answerSubmitted == -1)){
                if(self.activeQuestion != nil){
                    let selectedAnswer = self.activeQuestion?.responses[row] ?? ""
                    let isCorrect = quizSession.submit(response: selectedAnswer, for: self.activeQuestion!)
                    let cell = collectionView.cellForItem(at: indexPath) as! QuestionAnswerCollectionViewCell
                    if(self.mode == .Test){
                        cell.setColor(answerColor: .Selected)
                        self.resetAllOtherCells(except: row)
                    }else{
                        if(isCorrect){
                            print("correct")
                            cell.setColor(answerColor: .Correct)
                            self.resetAllOtherCells(except: row)
                            
                        }else{
                            print("Wrong answer: \(selectedAnswer)")
                            cell.setColor(answerColor: .Incorrect)
                            var c = 0
                            let num = collectionView.numberOfItems(inSection: indexPath.section)
                            while c < num{
                                let cell = collectionView.cellForItem(at: IndexPath(item: c, section: indexPath.section)) as! QuestionAnswerCollectionViewCell
                                let option = cell.answerLabel.text ?? ""
                                if(option == self.activeQuestion?.correctResponse){
                                    cell.setColor(answerColor: .Correct)
                                    c = num
                                }
                                c += 1
                            }
                            
                        }
                        //set others
                        
                    }
                    self.answerSubmitted = row
                    
                }
                
            }
        }else{
            self.nextQuestion()
        }
    }
    
    /// Resets the color of each cell to normal, except the indicated one
    /// - Parameters:
    ///     - except: `Int ` of cell to not change the color of
    func resetAllOtherCells(except:Int){
        var c = 0
        while c < self.collectionView.numberOfItems(inSection: 0){
            let cell = self.collectionView.cellForItem(at: IndexPath(item: c, section: 0)) as! QuestionAnswerCollectionViewCell
            if(c != except){
            cell.setColor(answerColor: .Normal)
            }
            c += 1
        }
    }
    
    /// Labels the answer A,B,C,D, etc
    /// - Parameters:
    ///     - indexPath: `indexPath` index of the current answer
    ///- Returns: `String` with a letter (A, B, C, D, etc)
    func generateAnswerIdForIndexPath(indexPath:IndexPath)->String{
        let row = indexPath.row
        
        switch row {
        case 0:
            return "A"
        case 1:
            return "B"
        case 2:
            return "C"
        case 3:
            return "D"
        case 4:
            return "E"
        case 5:
            return "F"
        case 6:
            return "G"
            
        default:
            return "?"
        }
        
    }
    
    enum QuizMode {
        case Study
        case Test
    }
}



extension QuestionCollectionViewController: UICollectionViewDelegateFlowLayout {
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //        print(indexPath)
    //        return CGSize(width: self.view.frame.size.width, height: 425)
    //    }
    
    // func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout)
}
