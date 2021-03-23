package MicroProcessor;

public class MicroProcessorFactory extends MicroProcessorBuilder {

    public MicroProcessor getMicroProcessor(String microProcessorName, String internetConnection) {
        if(microProcessorName.equalsIgnoreCase("ATMega32")) {
            return buildATMega32(internetConnection);
        }
        else if(microProcessorName.equalsIgnoreCase("Arduino")) {
            return buildArduino(internetConnection);
        }
        else if(microProcessorName.equalsIgnoreCase("RaspberryPi")) {
            return buildRaspberryPi(internetConnection);
        }
        else {
            return null;
        }
    }
}
