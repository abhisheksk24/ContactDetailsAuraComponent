public class FutureDemo {

    public void invokeFutureCall(){

        String primitiveValue = 'Input to future method';
        List<String> listofPrimitiveValue = new List<String>{primitiveValue};
        
        futureMethod1(listofPrimitiveValue);
        futureMethod2();
        futureMethod3();

    }

    @future
    public static void futureMethod1(List<String> inputParam){
        System.debug('Inside futureMethod1');
        System.debug('inputParam: ' + inputParam);
    }

    @future
    public static void futureMethod2(){
        System.debug('Inside futureMethod2');
    }

    @future
    public static void futureMethod3(){
        System.debug('Inside futureMethod3');
    }

}