//
//  ViewController.m
//  ble obc
//
//  Created by 安達康平 on 2016/07/15.
//  Copyright © 2016年 Kohei Adachi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize sw;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //Centralの初期処理
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [centralManager setDelegate:self];
     [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    //画面の初期化
    _btnScan.enabled = false;
    _btnConnect.enabled = false;
    _btnClose.enabled = false;
    
    _txtStatus.text = @"";
    _txtNotifyData.text = @"";
    
    UUIDService = @"D96A513D-A6D8-4F89-9895-CA131A0935CB";
    //TurtleのUUID
    UUIDCharacteristics = @"C3AE33E1-E40C-4137-A040-ADBAB921D894";
    //CharacteristicsのUUID
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if(central.state == CBCentralManagerStatePoweredOn) {
        //scanボタンを有効にする
        _btnScan.enabled = true;
        _txtStatus.text = @"初期化完了";
    }
}
- (IBAction)kaiseki:(id)sender {
    [self kaiseki];
}

- (IBAction)SwitchChanged:(id)sender {
    if(sw.on){
        _swlabel.text=@"1";
        //ここにスイッチがONになったときにやりたいことを記述
      //  NSLog(@"スイッチがONになりました");
        
    }else{
        
        //ここにスイッチがOFFになったときにやりたいことを記述
       // NSLog(@"スイッチがOFFになりました");
       _swlabel.text=@"0";
        
    }


}

- (IBAction)OnBtnScan:(id)sender {
    
    _btnScan.enabled = false;
    _txtStatus.text = @"スキャン中";
    
    CBUUID *uuid = [CBUUID UUIDWithString:UUIDService];
    NSArray *services = [NSArray arrayWithObjects:uuid,nil];
    
    [centralManager scanForPeripheralsWithServices:services
                                           options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:YES]}];}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    //スキャンの終了
    [centralManager stopScan];
    
    //ペリフェラルを保持する（ここではペリフェラルは単独）
    targetPeripheral = aPeripheral;
    targetPeripheral.delegate = self;
    
    _btnConnect.enabled = true;
    _txtStatus.text = @"turtle検知";
}

- (IBAction)OnBtnConnect:(id)sender {
    _btnConnect.enabled = false;
    _txtStatus.text = @"サービススキャン中";
    
    [centralManager connectPeripheral:targetPeripheral options:nil];
    
    
    
    
    
    }

- (IBAction)read:(id)sender {
 [centralManager connectPeripheral:targetPeripheral options:nil];

}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //サービスを探す
    [peripheral discoverServices:nil];
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    
    for (CBService *aService in aPeripheral.services){
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:UUIDService]]) {
            [aPeripheral discoverCharacteristics:@[[CBUUID UUIDWithString:UUIDCharacteristics]]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    /// Characteristic に対して Notify を受け取れるようにする
    for (CBService *service in peripheral.services) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    _txtStatus.text = @"Notify受付中";
    _btnClose.enabled = true;



}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    _txtStatus.text = @"Notify完了";
    
   // NSString *stringFromData =[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
  //  NSLog(@"characteristic.value : %@", characteristic.value);
   // NSLog(@"characteristic.UUID : %@", characteristic.UUID);
    NSString *str =[NSString stringWithFormat:@"%@",characteristic.value];
     _txtNotifyData.text = str;
 /*
    NSArray *array = [str componentsSeparatedByString:@" "];
    NSLog(@"array:%@", [array description]);
   */ 
    /* スペース.を区切りに文字列を抽出 */
    unsigned int result;
    unsigned int resultb;
    unsigned int xaxisold;
    unsigned int yaxisold;
    unsigned int zaxisold;
    NSString*Battery = [str substringWithRange:NSMakeRange([str length]-3, 2)];
 //   NSLog(@"%@",Battery);
    NSString*Temperature = [str substringWithRange:NSMakeRange([str length]-5, 2)];
    [[NSScanner scannerWithString:Battery] scanHexInt:&resultb];
    [[NSScanner scannerWithString:Temperature] scanHexInt:&result];
    NSString*Zaxis = [str substringWithRange:NSMakeRange([str length]-7, 2)];
    NSString*Yaxis = [str substringWithRange:NSMakeRange([str length]-9, 2)];
    NSString*Xaxis = [str substringWithRange:NSMakeRange([str length]-12, 2)];
    NSString*Respiration1 = [str substringWithRange:NSMakeRange(12, 4)];
    NSString*Respiration2 = [str substringWithRange:NSMakeRange(16, 5)];
    NSString*Respiration3 = [str substringWithRange:NSMakeRange(21, 4)];
    NSString*Respiration4 = [str substringWithRange:NSMakeRange(25, 5)];
    NSString*Respiration5 = [str substringWithRange:NSMakeRange(30, 4)];
    /*
    _z.text=Zaxis;
    _y.text=Yaxis;
    _x.text=Xaxis;
     */
     [[NSScanner scannerWithString:Xaxis] scanHexInt:&xaxisold];
    [[NSScanner scannerWithString:Yaxis] scanHexInt:&yaxisold];
    [[NSScanner scannerWithString:Zaxis] scanHexInt:&zaxisold];
    _res1.text=Respiration1;
    _res2.text=Respiration2;
    _res3.text=Respiration3;
    _res4.text=Respiration4;
    _res5.text=Respiration5;
    NSString *xaxis =[NSString stringWithFormat:@"%d", xaxisold];
    NSString *yaxis =[NSString stringWithFormat:@"%d", yaxisold];
     NSString *zaxis =[NSString stringWithFormat:@"%d", zaxisold];
   _btnScan.enabled = true;
    _z.text=zaxis;
    _y.text=yaxis;
    _x.text=xaxis;
 //   NSLog(@"%@",Temperature);
   int a = self.swlabel.text.floatValue;
    NSString *temp =[NSString stringWithFormat:@"%d", result];
    NSString *battery =[NSString stringWithFormat:@"%d", resultb];
    
 //   NSLog(@"%d,%d,%d,%d",a,xaxisold,yaxisold,zaxisold);
    
    _temp.text=temp;
    
    _battery.text=battery;
    
    NSNotification *n = [NSNotification notificationWithName:@"うつ伏せです" object:self];
    int  o;
    if(yaxisold>=3&&zaxisold>=191)
        _state.text=@"仰向け";
    else if((xaxisold>=44&&yaxisold>=34)||yaxisold<=66||zaxisold<=67)
      //  _state.text=@"うつ伏せ";
            o=1;
    else
        _state.text=@"";
    if(o==1){
        _state.text=@"うつ伏せ";
        [[NSNotificationCenter defaultCenter] postNotification:n];
        [self correctans];
    }
    [self keisan];
    
    /*
    else if(xaxisold>=229&&yaxisold>=13)
        _state.text=@"右";
    else if(xaxisold<=10&&yaxisold<=208)
        _state.text=@"左";
*/
}


- (IBAction)OnBtnClose:(id)sender {
    [centralManager cancelPeripheralConnection:targetPeripheral];
    _btnClose.enabled = false;
}
-(void)close{
    
    [centralManager cancelPeripheralConnection:targetPeripheral];
    _btnScan.enabled = true;

}

-(void)scan{
    
    _btnScan.enabled = false;
    _txtStatus.text = @"スキャン中";
    
    CBUUID *uuid = [CBUUID UUIDWithString:UUIDService];
    NSArray *services = [NSArray arrayWithObjects:uuid,nil];
    
    [centralManager scanForPeripheralsWithServices:services
                                           options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:YES]}];
}
-(void)keisan{
NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int i = [ud integerForKey:@"KEY_X"];
    int j = [ud integerForKey:@"KEY_Y"];
    int k = [ud integerForKey:@"KEY_Z"];
    int  a = self.x.text.floatValue;
    int  b = self.y.text.floatValue;
    int  c = self.z.text.floatValue;
    int sa1=0,sa2=0,sa3=0,sa4=0,sa5=0,sa6=0;
    int total;
    int  inc = [ud integerForKey:@"inc"];
 //   NSLog(@"%d",inc);
    inc++;
    if(inc>10){
        inc=0;
    }
    [ud setInteger:inc forKey:@"inc"];
    
    /*
    NSString *hairetu;
    NSString *hairetu1;
    NSString *hairetu2;
    NSString *hairetu3;
    NSString *hairetu4;
    NSString *hairetu5;
    NSString *hairetu6;
    NSString *hairetu7;
    NSString *hairetu8;
    NSString *hairetu9;
     */
    if(i!=0&&j!=0&&k!=0){
        sa1=a-i;
        sa2=b-j;
        sa3=c-k;
        
    }
    sa4=abs(sa1);
    sa5=abs(sa2);
    sa6=abs(sa3);
     total=sa4+sa5+sa6;
    if(inc==0){
    [ud setInteger:total forKey:@"hairetu"];
    }
    if(inc==1){
        [ud setInteger:total forKey:@"hairetu1"];
    }
    if(inc==2){
        [ud setInteger:total forKey:@"hairetu2"];
    }
    if(inc==3){
        [ud setInteger:total forKey:@"hairetu3"];
    }
    if(inc==4){
        [ud setInteger:total forKey:@"hairetu4"];
    }
    if(inc==5){
        [ud setInteger:sa1 forKey:@"hairetu5"];
    }
    if(inc==6){
        [ud setInteger:sa1 forKey:@"hairetu6"];
    }
    if(inc==7){
        [ud setInteger:a forKey:@"hairetu7"];
    }
    if(inc==8){
        [ud setInteger:a forKey:@"hairetu8"];
    }
    if(inc==9){
        [ud setInteger:a forKey:@"hairetu9"];
    }
    if(inc==10){
        [self kaiseki];
    }

    
    NSString *dif1 =[NSString stringWithFormat:@"%d", sa4];
    NSString *dif2 =[NSString stringWithFormat:@"%d", sa5];
    NSString *dif3 =[NSString stringWithFormat:@"%d", sa6];
    
    
    _act1.text=dif1;
    _act2.text=dif2;
    _act3.text=dif3;
    
  //  NSLog(@"%d,%d,%d",sa1,sa2,sa3);
  //  NSlog(@"%d",total);
  //  total=sa4+sa5+sa6;
    if(total>=100)
        _active.text=@"Active";
    else
        _active.text=@"";
    
    
    
    
    /*
    int  a = self.x.text.floatValue;
    int  b = self.y.text.floatValue;
    int  c = self.z.text.floatValue;
    */
    
[ud setInteger:a forKey:@"KEY_X"];
 [ud setInteger:b forKey:@"KEY_Y"];
 [ud setInteger:c forKey:@"KEY_Z"];
    
    
}
-(void)kaiseki{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int  hensu1 = [ud integerForKey:@"hairetu"];
     int  hensu2 = [ud integerForKey:@"hairetu1"];
     int  hensu3 = [ud integerForKey:@"hairetu2"];
     int  hensu4 = [ud integerForKey:@"hairetu3"];
     int  hensu5 = [ud integerForKey:@"hairetu4"];
     int  hensu6 = [ud integerForKey:@"hairetu5"];
     int  hensu7 = [ud integerForKey:@"hairetu6"];
     int  hensu8 = [ud integerForKey:@"hairetu7"];
     int  hensu9 = [ud integerForKey:@"hairetu8"];
     int  hensu10 = [ud integerForKey:@"hairetu9"];
    NSLog(@"%d,%d,%d,%d",hensu1,hensu2,hensu3,hensu4);
    int j,k,n;
    double p,q,xx,x[4],f[4],x1,x2,x3,x4,q1 = 0.0,q2 = 0.0,q3 = 0.0,q4 = 0.0,p1 = 0.0,p2 = 0.0,p3 = 0.0,p4 = 0.0;
    
    n=3;
    x[0]=1;
    x[1]=2;
    x[2]=3;
    x[3]=4;
    f[0]=hensu1;
    f[1]=hensu2;
    f[2]=hensu3;
    f[3]=hensu4;
    xx=1.00;
    x1=2.01;
    x2=3.01;
    x3=4.01;
    x4=5.01;
    p=hensu1;
    for(k=0;k<=n;k++){
        q=1;
        q1=1;
        q2=1;
        q3=1;
        q4=1;
        for (j=0; j<=n; j++) {
            if(j!=k)
                q=q*(xx-x[j])/(x[k]-x[j]);
                q1=q*(x1-x[j])/(x[k]-x[j]);
                q2=q*(x2-x[j])/(x[k]-x[j]);
            q3=q*(x3-x[j])/(x[k]-x[j]);
            q4=q*(x4-x[j])/(x[k]-x[j]);
           // q5=q*(x1-x[j])/(x[k]-x[j]);
            
        }
        p=p+f[k]*q;
        p1=p1+f[k]*q1;
        p2=p2+f[k]*q2;
        p3=p3+f[k]*q3;
        p4=p4+f[k]*q4;
    }
    NSLog(@"%lf",p);
    NSLog(@"%lf",p1);
    NSLog(@"%lf",p2);
    NSLog(@"%lf",p3);
    NSLog(@"%lf",p4);
    //NSLog(@"%lf",p5);
    
      NSString *dif1 =[NSString stringWithFormat:@"%lf", p];
    
    _kaisekilabel.text = dif1;
    
}
-(void)correctans{
    NSString *bgmPath =[[NSBundle mainBundle]pathForResource:@"decision13" ofType:@"mp3"];
    NSURL   *bgmurl =[NSURL fileURLWithPath:bgmPath];
    sound   =[[AVAudioPlayer alloc] initWithContentsOfURL:bgmurl error:nil];
    [sound  setNumberOfLoops:0];
    [sound play];
}
@end
