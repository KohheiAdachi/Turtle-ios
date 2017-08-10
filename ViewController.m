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
    
    //ペリフェラルUUIDの設定
    UUIDService = @"D96A513D-A6D8-4F89-9895-CA131A0935CB";
    UUIDCharacteristics = @"C3AE33E1-E40C-4137-A040-ADBAB921D894";
  
    
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
                                           options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:YES]}];

    [self resetDefaults];

}

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
// NSLog(@"%@", characteristic.value);
   // NSLog(@"characteristic.UUID : %@", characteristic.UUID);
    NSString *str =[NSString stringWithFormat:@"%@",characteristic.value];
   //  _txtNotifyData.text = str;
   // _valuelabel.text = str;
    
    
    
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
  //  _res1.text=Respiration1;
   // _res2.text=Respiration2;
   // _res3.text=Respiration3;
   // _res4.text=Respiration4;
   // _res5.text=Respiration5;
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
    
  //  NSLog(@"%d,%d,%d,%d",a,xaxisold,yaxisold,zaxisold);
    
    _temp.text=temp;
    
    _battery.text=battery;
    
   
    int  o;
    if((xaxisold>=44&&yaxisold>=34)||zaxisold<=67){
        _state.text=@"うつ伏せ";
            o=1;
        [self correctans];
    }
    else{
       _state.text=@"仰向け";
    }
       // _state.text=@"";
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
    NSUserDefaults*ud2= [[NSUserDefaults alloc] initWithSuiteName:@"group.b.ble-obc"];
    int i = [ud integerForKey:@"KEY_X"];
    int j = [ud integerForKey:@"KEY_Y"];
    int k = [ud integerForKey:@"KEY_Z"];
    int  a = self.x.text.floatValue;
    int  b = self.y.text.floatValue;
    int  c = self.z.text.floatValue;
    int sa1=0,sa2=0,sa3=0,sa4=0,sa5=0,sa6=0;
    int total;
    int  inc = [ud integerForKey:@"inc"];
    [ud2 setInteger:c forKey:@"suji"];
 //   NSLog(@"%d",inc);
    inc++;
    
    /*
    if(inc>10){
        inc=0;
    }
     */
    if(inc>10){
        inc=1;
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
  
    if(inc==1){
        [ud setInteger:a forKey:@"hairetu"];
        [ud setInteger:b forKey:@"hairetuY"];
        [ud setInteger:c forKey:@"hairetuZ"];
        NSString *axis =[NSString stringWithFormat:@"X=%.3d,Y=%.3d,Z=%.3d", a,b,c];
        _xyz1.text = axis;
        _xyz1.backgroundColor = [UIColor redColor];
           _xyz10.backgroundColor = nil;
        
    }
    if(inc==2){
        [ud setInteger:a forKey:@"hairetu1"];
        [ud setInteger:b forKey:@"hairetu1Y"];
        [ud setInteger:c forKey:@"hairetu1Z"];
        NSString *axis =[NSString stringWithFormat:@"X=%.3d,Y=%.3d,Z=%.3d", a,b,c];
        _xyz2.text = axis;
        _xyz1.backgroundColor = nil;
        _xyz2.backgroundColor = [UIColor redColor];
    }
    if(inc==3){
        [ud setInteger:a forKey:@"hairetu2"];
        [ud setInteger:b forKey:@"hairetu2Y"];
        [ud setInteger:c forKey:@"hairetu2Z"];
        NSString *axis =[NSString stringWithFormat:@"X=%.3d,Y=%.3d,Z=%.3d", a,b,c];
        _xyz3.text = axis;
        _xyz2.backgroundColor = nil;
        _xyz3.backgroundColor = [UIColor redColor];
    }
    if(inc==4){
        [ud setInteger:a forKey:@"hairetu3"];
        [ud setInteger:b forKey:@"hairetu3Y"];
        [ud setInteger:c forKey:@"hairetu3Z"];
        NSString *axis =[NSString stringWithFormat:@"X=%.3d,Y=%.3d,Z=%.3d", a,b,c];
        _xyz4.text = axis;
        _xyz3.backgroundColor = nil;
        _xyz4.backgroundColor = [UIColor redColor];
    }
    if(inc==5){
        [ud setInteger:a forKey:@"hairetu4"];
        [ud setInteger:b forKey:@"hairetu4Y"];
        [ud setInteger:c forKey:@"hairetu4Z"];
        NSString *axis =[NSString stringWithFormat:@"X=%.3d,Y=%.3d,Z=%.3d", a,b,c];
        _xyz5.text = axis;
        _xyz4.backgroundColor = nil;
        _xyz5.backgroundColor = [UIColor redColor];
    }
    if(inc==6){
        [ud setInteger:a forKey:@"hairetu5"];
        [ud setInteger:b forKey:@"hairetu5Y"];
        [ud setInteger:c forKey:@"hairetu5Z"];
        NSString *axis =[NSString stringWithFormat:@"X=%.3d,Y=%.3d,Z=%.3d", a,b,c];
        _xyz6.text = axis;
        _xyz5.backgroundColor = nil;
        _xyz6.backgroundColor = [UIColor redColor];
    }
    if(inc==7){
        [ud setInteger:a forKey:@"hairetu6"];
        [ud setInteger:b forKey:@"hairetu6Y"];
    [ud setInteger:c forKey:@"hairetu6Z"];
        NSString *axis =[NSString stringWithFormat:@"X=%.3d,Y=%.3d,Z=%.3d", a,b,c];
        _xyz7.text = axis;
        _xyz6.backgroundColor = nil;
        _xyz7.backgroundColor = [UIColor redColor];
    }
    if(inc==8){
        [ud setInteger:a forKey:@"hairetu7"];
        [ud setInteger:b forKey:@"hairetu7Y"];
        [ud setInteger:c forKey:@"hairetu7Z"];
        NSString *axis =[NSString stringWithFormat:@"X=%.3d,Y=%.3d,Z=%.3d", a,b,c];
        _xyz8.text = axis;
        _xyz7.backgroundColor = nil;
        _xyz8.backgroundColor = [UIColor redColor];
    }
    if(inc==9){
        [ud setInteger:a forKey:@"hairetu8"];
        [ud setInteger:b forKey:@"hairetu8Y"];
        [ud setInteger:c forKey:@"hairetu8Z"];
        NSString *axis =[NSString stringWithFormat:@"X=%.3d,Y=%.3d,Z=%.3d", a,b,c];
        _xyz9.text = axis;
        _xyz8.backgroundColor = nil;
        _xyz9.backgroundColor = [UIColor redColor];
    }
    if(inc==10){
        [ud setInteger:a forKey:@"hairetu9"];
        [ud setInteger:b forKey:@"hairetu9Y"];
        [ud setInteger:c forKey:@"hairetu9Z"];
        NSString *axis =[NSString stringWithFormat:@"X=%.3d,Y=%.3d,Z=%.3d", a,b,c];
        _xyz10.text = axis;
        _xyz9.backgroundColor = nil;
        _xyz10.backgroundColor = [UIColor redColor];
        [self kaiseki];
        [self kaiseki2];
          [self kaiseki3];
        [self kaiseki4];

    }
    if(inc%2==1){
        [ud setInteger:a forKey:@"naisekiX"];
        [ud setInteger:b forKey:@"naisekiY"];
        [ud setInteger:c forKey:@"naisekiZ"];
    }
    if(inc%2==0){
        [ud setInteger:a forKey:@"naisekiX2"];
        [ud setInteger:b forKey:@"naisekiY2"];
        [ud setInteger:c forKey:@"naisekiZ2"];
        [self vecter];
    }
    
    
    /*
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
        [ud setInteger:total forKey:@"hairetu5"];
    }
    if(inc==6){
        [ud setInteger:total forKey:@"hairetu6"];
    }
    if(inc==7){
        [ud setInteger:total forKey:@"hairetu7"];
    }
    if(inc==8){
        [ud setInteger:total forKey:@"hairetu8"];
    }
    if(inc==9){
        [ud setInteger:total forKey:@"hairetu9"];
    }
    if(inc==10){
        [self kaiseki];
    }
*/
    
    NSString *dif1 =[NSString stringWithFormat:@"%d", sa4];
    NSString *dif2 =[NSString stringWithFormat:@"%d", sa5];
    NSString *dif3 =[NSString stringWithFormat:@"%d", sa6];
    
    
    _act1.text=dif1;
    _act2.text=dif2;
    _act3.text=dif3;
    
  //  NSLog(@"%d,%d,%d",sa1,sa2,sa3);
  //  NSlog(@"%d",total);
  //  total=sa4+sa5+sa6;
  /*
    if(total>=100)
        _active.text=@"Active";
    else
        _active.text=@"";
    */
    
    
    
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
    int a1 = [ud integerForKey:@"hairetu"];
    int a2 = [ud integerForKey:@"hairetu1"];
    int a3 = [ud integerForKey:@"hairetu2"];
    int a4 = [ud integerForKey:@"hairetu3"];
    int a5 = [ud integerForKey:@"hairetu4"];
    int a6 = [ud integerForKey:@"hairetu5"];
    int a7 = [ud integerForKey:@"hairetu6"];
    int a8 = [ud integerForKey:@"hairetu7"];
    int a9 = [ud integerForKey:@"hairetu8"];
    int a10 = [ud integerForKey:@"hairetu9"];

    int b1 = [ud integerForKey:@"hairetuY"];
    int b2 = [ud integerForKey:@"hairetu1Y"];
    int b3 = [ud integerForKey:@"hairetu2Y"];
    int b4 = [ud integerForKey:@"hairetu3Y"];
    int b5 = [ud integerForKey:@"hairetu4Y"];
    int b6 = [ud integerForKey:@"hairetu5Y"];
    int b7 = [ud integerForKey:@"hairetu6Y"];
    int b8 = [ud integerForKey:@"hairetu7Y"];
    int b9 = [ud integerForKey:@"hairetu8Y"];
    int b10 = [ud integerForKey:@"hairetu9Y"];
    
    int c1 = [ud integerForKey:@"hairetuZ"];
    int c2 = [ud integerForKey:@"hairetu1Z"];
    int c3 = [ud integerForKey:@"hairetu2Z"];
    int c4 = [ud integerForKey:@"hairetu3Z"];
    int c5 = [ud integerForKey:@"hairetu4Z"];
    int c6 = [ud integerForKey:@"hairetu5Z"];
    int c7 = [ud integerForKey:@"hairetu6Z"];
    int c8 = [ud integerForKey:@"hairetu7Z"];
    int c9 = [ud integerForKey:@"hairetu8Z"];
    int c10 = [ud integerForKey:@"hairetu9Z"];

    
    int total1 = a1+b1+c1;
    int total2 = a2+b2+c2;
    int total3 = a3+b3+c3;
    int total4 = a4+b4+c4;
     int total5 = a5+b5+c5;
     int total6 = a6+b6+c6;
     int total7 = a7+b7+c7;
     int total8 = a8+b8+c8;
     int total9 = a9+b9+c9;
     int total10 = a10+b10+c10;
  //  int total = a1+a2+a3+a4+a5;
    
   
    
    int a;
   // double data[] = {a1, a2, a3, a4,a5,a6,a7,a8,a9,a10};
    double data[] = {total1, total2, total3, total4,total5,total6,total7,total8,total9,total10};
    int n = sizeof(data)/sizeof(double);
    double avg=0.0, dev=0.0, sum = 0.0, sum2 = 0.0;
    
    for (a = 0; a < n; a++) {
        sum  += data[a];
        sum2 += data[a]*data[a];
    }
    avg = sum/n;
    dev = sqrt(sum2/n - avg*avg);
 //  NSLog(@"%lf,%lf",avg,dev);
      NSString *hensa =[NSString stringWithFormat:@"%.3f", dev];
    _hensa.text=hensa;
    int hensu=0;
    
    if(dev>=10)
        hensu=1;
        //_active.text=@"Active";
    else
        _active.text=@"";
    if(hensu==1){
        _active.text=@"Active";
        [self hyouzi];
    }
}
-(void)correctans{
    NSString *bgmPath =[[NSBundle mainBundle]pathForResource:@"decision13" ofType:@"mp3"];
    NSURL   *bgmurl =[NSURL fileURLWithPath:bgmPath];
    sound   =[[AVAudioPlayer alloc] initWithContentsOfURL:bgmurl error:nil];
    [sound  setNumberOfLoops:0];
    [sound play];
}

- (void)resetDefaults {
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}
-(void)kaiseki2{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];//Y軸の解析
    int b1 = [ud integerForKey:@"hairetu"];
    int b2 = [ud integerForKey:@"hairetu1"];
    int b3 = [ud integerForKey:@"hairetu2"];
    int b4 = [ud integerForKey:@"hairetu3"];
    int b5 = [ud integerForKey:@"hairetu4"];
    int b6 = [ud integerForKey:@"hairetu5"];
    int b7 = [ud integerForKey:@"hairetu6"];
    int b8 = [ud integerForKey:@"hairetu7"];
    int b9 = [ud integerForKey:@"hairetu8"];
    int b10 = [ud integerForKey:@"hairetu9"];
    int a;
    double data[] = {b1, b2, b3, b4,b5,b6,b7,b8,b9,b10};
    int n = sizeof(data)/sizeof(double);
    double avg, dev, sum = 0.0, sum2 = 0.0;
    
    for (a = 0; a < n; a++) {
        sum  += data[a];
        sum2 += data[a]*data[a];
    }
    avg = sum/n;
    dev = sqrt(sum2/n - avg*avg);
    NSLog(@"X軸%lf,%lf",avg,dev);
   
    
    
    /*
    if(dev>=10)
        _active.text=@"Active";
    else
        _active.text=@"";
    */
}
-(void)kaiseki3{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];//Y軸の解析
    int b1 = [ud integerForKey:@"hairetuY"];
    int b2 = [ud integerForKey:@"hairetu1Y"];
    int b3 = [ud integerForKey:@"hairetu2Y"];
    int b4 = [ud integerForKey:@"hairetu3Y"];
    int b5 = [ud integerForKey:@"hairetu4Y"];
    int b6 = [ud integerForKey:@"hairetu5Y"];
    int b7 = [ud integerForKey:@"hairetu6Y"];
    int b8 = [ud integerForKey:@"hairetu7Y"];
    int b9 = [ud integerForKey:@"hairetu8Y"];
    int b10 = [ud integerForKey:@"hairetu9Y"];
    int a;
    double data[] = {b1, b2, b3, b4,b5,b6,b7,b8,b9,b10};
    int n = sizeof(data)/sizeof(double);
    double avg, dev, sum = 0.0, sum2 = 0.0;
    
    for (a = 0; a < n; a++) {
        sum  += data[a];
        sum2 += data[a]*data[a];
    }
    avg = sum/n;
    dev = sqrt(sum2/n - avg*avg);
    NSLog(@"Y軸%lf,%lf",avg,dev);
    
    
    
    /*
     if(dev>=10)
     _active.text=@"Active";
     else
     _active.text=@"";
     */
}
-(void)kaiseki4{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];//X軸の解析
    int b1 = [ud integerForKey:@"hairetuZ"];
    int b2 = [ud integerForKey:@"hairetu1Z"];
    int b3 = [ud integerForKey:@"hairetu2Z"];
    int b4 = [ud integerForKey:@"hairetu3Z"];
    int b5 = [ud integerForKey:@"hairetu4Z"];
    int b6 = [ud integerForKey:@"hairetu5Z"];
    int b7 = [ud integerForKey:@"hairetu6Z"];
    int b8 = [ud integerForKey:@"hairetu7Z"];
    int b9 = [ud integerForKey:@"hairetu8Z"];
    int b10 = [ud integerForKey:@"hairetu9Z"];
    int a;
    double data[] = {b1, b2, b3, b4,b5,b6,b7,b8,b9,b10};
    int n = sizeof(data)/sizeof(double);
    double avg=0.0, dev=0.0, sum = 0.0, sum2 = 0.0;
    
    for (a = 0; a < n; a++) {
        sum  += data[a];
        sum2 += data[a]*data[a];
    }
    avg = sum/n;
    dev = sqrt(sum2/n - avg*avg);
    
    NSLog(@"Z軸%lf,%lf",avg,dev);
    /*
    if(dev>=10)
        _active.text=@"Active";
    else
        _active.text=@"";
     */
}
-(void)hyouzi{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int a=0;
    //[ud setInteger:a forKey:@"log"];
    int b1 = [ud integerForKey:@"log"];
    b1++;
    a++;
    //[ud setInteger:b1 forKey:@"log"];
    NSUserDefaults*ud2= [[NSUserDefaults alloc] initWithSuiteName:@"group.b.ble-obc"];
   // NSUbiquitousKeyValueStore *vStore= [NSUbiquitousKeyValueStore defaultStore];
    NSDate *nowdate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"yyyy/M/d"];
    NSString *datamoji = [formatter stringFromDate:nowdate];
    NSString *datamoji2 = [formatter2 stringFromDate:nowdate];
    //[ud2 setObject:datamoji forKey:@"userName"];

    
    
    if(b1==1){
        _activelog.text=datamoji;
        NSString *s1 = @"1";
        
        NSString *str = [NSString stringWithFormat:@"%@%@",datamoji2,s1];
     //   NSLog(@"%@",str);
        [ud2 setObject:datamoji forKey:str];
    [ud2 setInteger:b1 forKey:datamoji2];
        
    }
    if(b1==2){
        _activelog2.text=datamoji;
        NSString *s1 = @"2";
        NSString *str = [NSString stringWithFormat:@"%@%@",datamoji2,s1];
        
        [ud2 setObject:datamoji forKey:str];
        [ud2 setInteger:b1 forKey:datamoji2];
       
    }
    if(b1==3){
        _activelog3.text=datamoji;
        NSString *s1 = @"3";
        NSString *str = [NSString stringWithFormat:@"%@%@",datamoji2,s1];
        [ud2 setObject:datamoji forKey:str];
    [ud2 setInteger:b1 forKey:datamoji2];
        
    }
    if(b1==4){
        NSString *s1 = @"4";
        NSString *str = [NSString stringWithFormat:@"%@%@",datamoji2,s1];
        [ud2 setObject:datamoji forKey:str];
        [ud2 setInteger:b1 forKey:datamoji2];
    }
    if(b1==5){
        NSString *s1 = @"5";
        NSString *str = [NSString stringWithFormat:@"%@%@",datamoji2,s1];
        [ud2 setObject:datamoji forKey:str];
        [ud2 setInteger:b1 forKey:datamoji2];
    }
    if(b1==6){
        NSString *s1 = @"3";
        NSString *str = [NSString stringWithFormat:@"%@%@",datamoji2,s1];
        [ud2 setObject:datamoji forKey:str];
        [ud2 setInteger:b1 forKey:datamoji2];
        b1=0;
    }
  //  [ud setInteger:a forKey:@"log"];
     [ud setInteger:b1 forKey:@"log"];
    //[vStore setString:@"I'm live in iCloud!" forKey:@"inputText"];
}
-(void)vecter{                                      //ベクトル解析
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int a1 = [ud integerForKey:@"naisekiX"];
    int b1 = [ud integerForKey:@"naisekiY"];
    int c1 = [ud integerForKey:@"naisekiZ"];
    int a2 = [ud integerForKey:@"naisekiX2"];
    int b2 = [ud integerForKey:@"naisekiY2"];
    int c2 = [ud integerForKey:@"naisekiZ2"];
    
    double vec1[] = {0.0, 0.0, 0.0};
    double vec2[] = {a2, b2, c2};
    int i;
    double s = 0.0;
    
    for ( i = 0; i < 3; i++ ) {
        s += vec1[i] * vec2[i];
    }
    NSLog(@"内積: %.2f\n", s);
    
    
}

@end
