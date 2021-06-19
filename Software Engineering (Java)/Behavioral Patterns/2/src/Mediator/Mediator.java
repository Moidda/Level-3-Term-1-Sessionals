package Mediator;

import Components.*;

public interface Mediator {
    void notifyMediator(Component component, String service);
    void setJpdc(Component jpdc);
    void setJrta(Component jrta);
    void setJtrc(Component jtrc);
    void setJwsa(Component jwsa);
}
