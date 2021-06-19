package Components;

import Mediator.Mediator;

import java.util.LinkedList;
import java.util.Queue;

public abstract class Component {
    Mediator mediator;
    String name;
    Queue<String> serviceRequests;

    public Component(Mediator mediator) {
        this.mediator = mediator;
        serviceRequests = new LinkedList<String>();
    }

    public String getName() {
        return this.name;
    }

    /**
     * A component can request for a service, or provide a service.
     * addRequest() adds an incoming service request from another
     * component to this component's request Queue
     * */
    public void addRequest(String requestingComponent) {
        this.serviceRequests.add(requestingComponent);
    }

    /**
     * Providing service for the component at the top of the queue
     * */
    public void provideService() {
        if(this.serviceRequests.isEmpty()) {
            System.out.println("No pending requests");
            return;
        }
        System.out.println(this.name + " serves the request for " + this.serviceRequests.remove());
    }

    public abstract void requestService(String service);

    public void process(String instruction) {
        if(instruction.equalsIgnoreCase("serve"))
            this.provideService();
        else
            this.requestService(instruction);
    }
}
