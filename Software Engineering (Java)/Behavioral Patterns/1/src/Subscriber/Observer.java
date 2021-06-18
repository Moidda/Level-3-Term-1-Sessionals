package Subscriber;

/**
 * all of the concrete observer classes should implement Observer interface
 * and so must override/define an update() function
 * */
public interface Observer {
    void update(String message);
}
