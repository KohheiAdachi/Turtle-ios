//
//  ViewController.h
//  ble obc
//
//  Created by 安達康平 on 2016/07/15.
//  Copyright © 2016年 Kohei Adachi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>
@interface ViewController : UIViewController
<CBPeripheralManagerDelegate,UITextFieldDelegate>
{
    AVAudioPlayer   *sound;

    //セントラル
    CBCentralManager *centralManager;
    
    //ペリフェラル
    CBPeripheral *targetPeripheral;
    
    //ターゲットペリフェラル
    NSString* UUIDService;
    NSString* UUIDCharacteristics;
}


//画面関連
@property (weak, nonatomic) IBOutlet UIButton *btnScan;

@property (weak, nonatomic) IBOutlet UIButton *btnConnect;

@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@property (weak, nonatomic) IBOutlet UITextField *txtNotifyData;

@property (weak, nonatomic) IBOutlet UITextField *txtStatus;

@property (weak, nonatomic) IBOutlet UILabel *battery;

@property (weak, nonatomic) IBOutlet UILabel *temp;
@property (weak, nonatomic) IBOutlet UILabel *x;
@property (weak, nonatomic) IBOutlet UILabel *y;
@property (weak, nonatomic) IBOutlet UILabel *z;

@property (weak, nonatomic) IBOutlet UILabel *res1;
@property (weak, nonatomic) IBOutlet UILabel *res2;
@property (weak, nonatomic) IBOutlet UILabel *res3;
@property (weak, nonatomic) IBOutlet UILabel *res4;
@property (weak, nonatomic) IBOutlet UILabel *res5;

@property (weak, nonatomic) IBOutlet UISwitch *sw;

@property (weak, nonatomic) IBOutlet UILabel *swlabel;
@property (weak, nonatomic) IBOutlet UILabel *state;

@property (weak, nonatomic) IBOutlet UILabel *act1;

@property (weak, nonatomic) IBOutlet UILabel *act2;

@property (weak, nonatomic) IBOutlet UILabel *act3;
@property (weak, nonatomic) IBOutlet UILabel *active;

@property (weak, nonatomic) IBOutlet UILabel *kaisekilabel;

- (IBAction)SwitchChanged:(id)sender;

- (IBAction)OnBtnScan:(id)sender;

- (IBAction)OnBtnClose:(id)sender;

- (IBAction)OnBtnConnect:(id)sender;

- (IBAction)read:(id)sender;

@end

