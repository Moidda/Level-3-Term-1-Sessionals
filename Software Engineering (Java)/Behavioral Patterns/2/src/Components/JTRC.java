package Components;

import Mediator.Mediator;

/**
 * Provides telecommunication services
 * */
public class JTRC extends Component {
    public JTRC(Mediator mediator) {
        super(mediator);
        super.name = "JRTC";
    }
    public void telecomService() {
        System.out.println("JTRC providing telecomm services");
    }

    @Override
    public void requestService(String service) {
        System.out.println("JTRC requesting for " + service + " service");
        super.mediator.notifyMediator(this, service);
    }
}
