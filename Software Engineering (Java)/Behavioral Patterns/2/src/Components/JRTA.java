package Components;

import Mediator.Mediator;

/**
 * Provides Road and transport services
 * */
public class JRTA extends Component {

    public JRTA(Mediator mediator) {
        super(mediator);
        super.name = "JRTA";
    }

    public void transportService() {
        System.out.println("JRTA providing transport services");
    }

    @Override
    public void requestService(String service) {
        System.out.println("JRTA requesting for " + service + " service");
        super.mediator.notifyMediator(this, service);
    }
}
