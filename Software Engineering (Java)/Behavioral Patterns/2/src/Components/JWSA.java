package Components;

import Mediator.Mediator;

/**
 * Provides water services
 * */
public class JWSA extends Component {

    public JWSA(Mediator mediator) {
        super(mediator);
        super.name = "JWSA";
    }

    public void provideWater() {
        System.out.println("JWSA providing water service");
    }

    @Override
    public void requestService(String service) {
        System.out.println("JWSA requesting for " + service + " service");
        super.mediator.notifyMediator(this, service);
    }
}
