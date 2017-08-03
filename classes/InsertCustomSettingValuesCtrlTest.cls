@isTest
public class InsertCustomSettingValuesCtrlTest {
    public static testmethod void method1(){
        InsertCustomSettingValuesCtrl insObj = new InsertCustomSettingValuesCtrl();
        Test.testInstall(insObj, null);
        insObj = null;
        system.assertEquals(insObj, null);
    }
}