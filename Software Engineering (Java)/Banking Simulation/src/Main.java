import java.util.Scanner;

public class Main {
    
    public static void main(String[] args) {
        Bank bank = new Bank();

        Scanner scanner = new Scanner(System.in);
        while(true) {
            String operation = scanner.next();
            
            if(operation.equals("Create")) {
                String name = scanner.next();
                String accountType = scanner.next();
                int initialDeposit = Integer.parseInt(scanner.next());

                bank.create_account(name, accountType, initialDeposit);
            }
            else if(operation.equals("Deposit")) {
                int money = Integer.parseInt(scanner.next());
                bank.deposit(money);
            }
            else if(operation.equals("Withdraw")) {
                int money = Integer.parseInt(scanner.next());
                bank.withdraw(money);
            }
            else if(operation.equals("Request")) {
                int money = Integer.parseInt(scanner.next());
                bank.requestLoan(money);
            }
            else if(operation.equals("Query")) {
                bank.query();
            }
            else if(operation.equals("Lookup")) {
                String name = scanner.next();
                bank.lookup(name);
            }
            else if(operation.equals("Approve")) {
                String keyword = scanner.next();
                if(keyword.equals("Loan")) {
                    bank.approveLoan();
                }
            }
            else if(operation.equals("Change")) {
                String accountType = scanner.next();
                float newInterest = Float.parseFloat(scanner.next());
                bank.changeInterestRate(accountType, newInterest);
            }
            else if(operation.equals("See")) {
                bank.seeInternalFund();
            }
            else if(operation.equals("INC")) {
                bank.increase_year(1);
            }
            else if(operation.equals("Open")) {
                String name = scanner.next();
                bank.activateUser(name);
            }
            else if(operation.equals("Close")) {
                bank.closeCurrentUser();
            }
            else if(operation.equals("End")) {
                break;
            }
        }
        scanner.close();
    }
}
