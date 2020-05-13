//
//  SimilarityVC.swift
//  ImageSimilaritySort
//
//  Created by 조윤영 on 2020/05/13.
//  Copyright © 2020 조윤영. All rights reserved.
//

import UIKit
import Vision

class SimilarityVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let cellIdentifier = "SimilarCVCell"
    var sourceImage = "source_car"
    var modelData = [ ModelData(id: 0, imageName: "scene"),ModelData(id: 1, imageName: "bike_1"), ModelData(id: 2, imageName: "car_2"), ModelData(id: 3, imageName: "bike_2"), ModelData(id: 4, imageName: "car_1")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func processAction(_ sender: Any) {
        guard !self.modelData.isEmpty else {
            return
        }
        
        var observation: VNFeaturePrintObservation?
        var sourceObservation:VNFeaturePrintObservation?
        
        sourceObservation = featureprintObservationForImage(image:UIImage(named:sourceImage)!)
        
        var tempData = modelData
        
        tempData = modelData.enumerated().map {  (id,mD) in
            var model = mD
            
            if let uiimage = UIImage(named: model.imageName) {
                observation = featureprintObservationForImage(image: uiimage)
                
                do {
                    var distance = Float(0)
                    if let sourceObservation = sourceObservation {
                        try observation?.computeDistance(&distance, to: sourceObservation)
                        model.distance = "\(distance)"
                    }
                } catch {
                    print("error occurred...")
                }
            }
            return model
        }
        modelData = tempData.sorted(by:{Float($0.distance)! < Float($1.distance)!})
        
        collectionView.reloadData()
    }
    
    
    
}

extension SimilarityVC: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? SimilarCVCell
        
        let imgName = modelData[indexPath.row].imageName
        cell?.carImageView.image = UIImage(named: imgName)
        cell?.similarLabel.text = modelData[indexPath.row].distance
            
            
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = 280
        let height = 246
        return CGSize(width: width, height: height)
    }
    
    
}
extension SimilarityVC {
    
    func processImages() {
        
    }
    
    func featureprintObservationForImage(image: UIImage) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(cgImage:image.cgImage!, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        
        do {
            try requestHandler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            print("Vision Error: \(error)")
            return nil
        }
    }
}

struct ModelData:Identifiable {
    public let id: Int
    public var imageName:String
    public var distance:String = "NA"
}
