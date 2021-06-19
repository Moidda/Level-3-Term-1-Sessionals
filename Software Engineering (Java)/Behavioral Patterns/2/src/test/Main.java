package test;

import Components.*;
import Mediator.*;

import java.io.File;
import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Mediator mediator = new ConcreateMediator();

        Component jpdc = new JPDC(mediator);
        Component jrta = new JRTA(mediator);
        Component jtrc = new JTRC(mediator);
        Component jwsa = new JWSA(mediator);

        try (Scanner scanner = new Scanner(new File("src/test/input.txt"))) {
            while(scanner.hasNext()) {
                String str = scanner.nextLine();
                if(str.equalsIgnoreCase("init")) {
                    System.out.println("setting up stuffs");
                    mediator.setJpdc(jpdc);
                    mediator.setJrta(jrta);
                    mediator.setJtrc(jtrc);
                    mediator.setJwsa(jwsa);
                }
                else {
                    String[] words = str.split(" ");
                    if(words[0].equalsIgnoreCase("jpdc")) {
                        jpdc.process(words[1]);
                    }
                    else if(words[0].equalsIgnoreCase("jrta")) {
                        jrta.process(words[1]);
                    }
                    else if(words[0].equalsIgnoreCase("jtrc")) {
                        jtrc.process(words[1]);
                    }
                    else if(words[0].equalsIgnoreCase("jwsa")) {
                        jwsa.process(words[1]);
                    }
                }
            }
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
        }

        System.out.println("---End---");
    }
}
