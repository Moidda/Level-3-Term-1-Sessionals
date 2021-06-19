package Components;

import Mediator.Mediator;

/**
 * Provides energy
 * */
public class JPDC extends Component {

    public JPDC(Mediator mediator) {
        super(mediator);
        super.name = "JPDC";
    }

    public void powerService() {
        System.out.println("JPDC providing power service");
    }

    @Override
    public void requestService(String service) {
        System.out.println("JPDC requesting for " + service + " service");
        super.mediator.notifyMediator(this, service);
    }
}
