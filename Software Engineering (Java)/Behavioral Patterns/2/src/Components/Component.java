package Components;

import Mediator.Mediator;

import java.util.LinkedList;
import java.util.Queue;

public abstract class Component {
    Mediator mediator;
    String name;

    public Component(Mediator mediator) {
        this.mediator = mediator;
    }

    public String getName() {
        return this.name;
    }

    /**
     * A component can request for a service, or provide a service.
     * */
    public abstract void requestService(String service);

    public void provideService() {
        this.mediator.notifyMediator(this, "serve");
    }

    public void service(String message) {
        System.out.println(message);
    }

    public void process(String instruction) {
        if(instruction.equalsIgnoreCase("serve"))
            this.provideService();
        else
            this.requestService(instruction);
    }
}
