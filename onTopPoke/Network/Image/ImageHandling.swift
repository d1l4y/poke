//
//  ImageHandling.swift
//  onTopPoke
//
//  Created by Vinicius Augusto Dilay de Paula on 11/05/23.
//

import UIKit

protocol ImageHandling {
    func getImage(for id: Int, completion: @escaping (Result<UIImage, Error>) -> Void)
}
