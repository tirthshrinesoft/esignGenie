@isTest
public class SelectOptionSorterTest {
    public static testMethod void method1(){
        Selectoption[] opts = new Selectoption[] {};
            for (Integer idx = 0; idx < 50000; idx++) 
            opts.add(new Selectoption('v1', 'l1' + idx));
        
        SelectOptionSorter.doSort(opts, SelectOptionSorter.FieldToSort.Label);
        system.assertEquals(opts.size(), 50000);
    }
    
    public static testMethod void method2(){
        Selectoption[] opts = new Selectoption[] {
                                   new Selectoption('v1', 'l1'),
                                   new Selectoption('v5', 'l1'),
                                   new Selectoption('v2', 'l1'),
                                   new Selectoption('v6', 'l1'),
                                   new Selectoption('v8', 'l1')
                               };
       
       SelectOptionSorter.doSort(opts, SelectOptionSorter.FieldToSort.Value);
        system.assertEquals(opts.size(), 5);
    }
}