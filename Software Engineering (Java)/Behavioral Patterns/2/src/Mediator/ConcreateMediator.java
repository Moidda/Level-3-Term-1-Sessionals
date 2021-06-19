package Mediator;

import Components.*;

public class ConcreateMediator implements Mediator {
    Component jpdc;
    Component jrta;
    Component jtrc;
    Component jwsa;

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

    /**
     * When a component wants something (service), it notifies the mediator.
     * Upon receiving the notification, the mediator may do something on its
     * own or pass the request to another component
     * */
    @Override
    public void notifyMediator(Component component, String service) {
        if(service.equalsIgnoreCase("power")) {
            jpdc.addRequest(component.getName());
        }
        else if(service.equalsIgnoreCase("transport")) {
            jrta.addRequest(component.getName());
        }
        else if(service.equalsIgnoreCase("telecom")) {
            jtrc.addRequest(component.getName());
        }
        else if(service.equalsIgnoreCase("water")) {
            jwsa.addRequest(component.getName());
        }
        else {
            System.out.println("No such service available");
        }
    }
}
