import java.util.ArrayList;

public class Bank {

    private int internal_fund;
    private int years_passed;

    private Employee currentEmployee;
    private MD md = new MD();
    private Cashier cashier = new Cashier();
    private Officer officer = new Officer();
    private String employeeString;

    private Accounts currentUser;
    private ArrayList<Accounts> accounts = new ArrayList<Accounts>();

    Bank()
    {
        internal_fund = 1000000;
        years_passed = 0;
        currentEmployee = null;
        currentUser = null;

        System.out.println("Bank Created; MD; O1;O2; C1;C2;C3;C4;C5 created");
    }

    public void seeInternalFund()
    {
        currentEmployee.seeInternalFund(this);
    }

    public void changeInterestRate(String accountType, float newInterest)
    {
        currentEmployee.changeInterestRate(accountType, newInterest, accounts);
    }

    public void approveLoan()
    {
        if(currentEmployee == null) {
            System.out.println("Only an employee can approve loan");
            return;
        }
        for(int i = 0; i < accounts.size(); i++) {
            currentEmployee.approveLoan(accounts.get(i));
        }
    }

    public void lookup(String name)
    {
        if(currentEmployee == null) {
            System.out.println("Only an employee can lookup a user");
            return;
        }
        Accounts user = getUser(name);
        currentEmployee.lookup(user);
    }

    public void requestLoan(int amount)
    {
        if(currentUser == null) {
            System.out.println("No active user");
            return;
        }
        currentUser.requestLoan(amount);
    }

    public void query()
    {
        if(currentUser == null) {
            System.out.println("No active user");
            return;
        }
        System.out.print("Current Balance " + currentUser.getCurrentDeposit() + "$");
        if(currentUser.getCurrentLoan() > 0 && currentUser.isLoanApproved()) 
            System.out.print(", loan " + currentUser.getCurrentLoan() + "$");

        System.out.println("");
    }

    public void withdraw(int money)
    {
        if(currentUser == null) return;
        currentUser.withdraw(money);
    }

    public void closeCurrentUser()
    {
        if(currentUser != null) System.out.println("Transaction closed for " + currentUser.getName());
        else if(currentEmployee != null) System.out.println("Operations for " + employeeString + " closed");
        currentUser = null;
        currentEmployee = null;
    }

    public Accounts getUser(String name) 
    {
        for(int i = 0; i < accounts.size(); i++) { 
            if(accounts.get(i).getName().equals(name)) {
                return accounts.get(i);
            }
        }
        System.out.println("No such account");
        return null;
    }

    public void activateEmployee(String name)
    {
        boolean isLoanPending = false;
        for(Accounts ac: accounts) 
            if(ac.getCurrentLoan() > 0) 
                isLoanPending = true;
               
        if(name.equals("MD")) {
            currentEmployee = md;
            System.out.print(name + " is active");
            if(isLoanPending) 
                System.out.print(", there are loan approvals pending");
        
            System.out.println("");
            employeeString = name;
        }
        else if(name.equals("O1") || name.equals("O2")) {
            currentEmployee = officer;
            System.out.print(name + " is active");
            if(isLoanPending) 
                System.out.print(", there are loan approvals pending");

            System.out.println("");
            employeeString = name;
        }
        else if(name.equals("C1") || name.equals("C2") || name.equals("C3") || name.equals("C4") || name.equals("C5")) {
            System.out.println(name + " is active");
            currentEmployee = cashier;
            employeeString = name;
        }
        else {
            currentEmployee = null;
            System.out.println("Invalid operation");
        }
    }

    public void activateUser(String name)
    {
        currentUser = getUser(name);
        if(currentUser == null) {
            activateEmployee(name);
            return;
        }
        System.out.println("Welcome back, " + name);
        System.out.println(currentUser);
    }

    public void deposit(int money) 
    {
        if(currentUser == null)
            return;
        
        currentUser.deposit(money);
    }

    public void create_account(String name, String accountType, int initialDeposit)
    {
        for(Accounts ac: accounts) {
            if(ac.getName().equals(name)) {
                System.out.println("An account already uses this name.");
                return;
            }
        }
        Accounts newAccount = Accounts.create_account(name, accountType, initialDeposit);
        if(newAccount == null) return; 
        accounts.add(newAccount);
        currentUser = newAccount;
    }

    public void increase_year(int years)
    {
        System.out.println("One year has passed");
        years_passed += years;
        for(int i = 0; i < accounts.size(); i++) {
            accounts.get(i).increase_year(years);
        }
    }

    public void setFund(int fund)
    {
        internal_fund = fund;
    }
    public int getFund()
    {
        return internal_fund;
    }

    public void setYears(int x)
    {
        years_passed = x;
    }   
    public int getYears()
    {
        return years_passed;
    }

    public void print_all_accounts()
    {
        for(Accounts ac: accounts) {
            System.out.println(ac);
        }
        System.out.println("");
    }
}
