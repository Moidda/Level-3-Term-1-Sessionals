package Mediator;

import Components.*;

import java.util.LinkedList;
import java.util.Queue;

public class ConcreateMediator implements Mediator {
    Component jpdc;
    Component jrta;
    Component jtrc;
    Component jwsa;

    Queue<Component> jpdcQueue = new LinkedList<Component>();
    Queue<Component> jrtaQueue = new LinkedList<Component>();
    Queue<Component> jtrcQueue = new LinkedList<Component>();
    Queue<Component> jwsaQueue = new LinkedList<Component>();

    Queue<Component> getRequestQueue(Component provider) {
        if(provider.getName().equalsIgnoreCase("jpdc")) return jpdcQueue;
        if(provider.getName().equalsIgnoreCase("jrta")) return jrtaQueue;
        if(provider.getName().equalsIgnoreCase("jtrc")) return jtrcQueue;
        if(provider.getName().equalsIgnoreCase("jwsa")) return jwsaQueue;
        return null;
    }

    /**
     * When a component wants something (service), it notifies the mediator.
     * Upon receiving the notification, the mediator may do something on its
     * own or pass the request to another component.
     *
     * Here, when a component requests a for a servicce, mediator add that component
     * to that specific service provider's queue.
     *
     * When a component notifies the mediator that it wants to provide service,
     * mediator checks this component's request queue and provides service to
     * the requesting component.
     * */
    @Override
    public void notifyMediator(Component component, String service) {
        // component requesting for a service
        if(service.equalsIgnoreCase("power")) {
            jpdcQueue.add(component);
        }
        else if(service.equalsIgnoreCase("transport")) {
            jrtaQueue.add(component);
        }
        else if(service.equalsIgnoreCase("telecom")) {
            jtrcQueue.add(component);
        }
        else if(service.equalsIgnoreCase("water")) {
            jwsaQueue.add(component);
        }

        // component is providing service
        else if(service.equalsIgnoreCase("serve")) {
            Queue<Component> requestQueue = getRequestQueue(component);
            if(requestQueue.isEmpty()) {
                System.out.println("Request queue for " + component.getName() + " is clear.");
                return;
            }
            Component requester = requestQueue.remove();
            component.service(component.getName() + " serves the request of " + requester.getName());
        }

        else {
            System.out.println("No such service available");
        }
    }

    @Override
    public void setJpdc(Component jpdc) {
        this.jpdc = jpdc;
    }

    @Override
    public void setJrta(Component jrta) {
        this.jrta = jrta;
    }

    @Override
    public void setJtrc(Component jtrc) {
        this.jtrc = jtrc;
    }

    @Override
    public void setJwsa(Component jwsa) {
        this.jwsa = jwsa;
    }
}
