import java.lang.Math;

public class Accounts {

    private String name;
    private String accountType;
    
    private int currentDeposit;
    private float interest;
    private int maturityPeriod;

    private int currentLoan;
    private boolean isLoanApproved;
    private int maxLoanRequest;
    private int loanInterest = 10;

    Accounts()
    {

    }

    Accounts(String name, String accountType, int initialDeposit)
    {
        this.name = name;
        this.accountType = accountType;
        this.currentDeposit = initialDeposit;
        this.maturityPeriod = 0;
        currentLoan = 0;
        isLoanApproved = false;
    }

    public void requestLoan(int amount)
    {
        if(amount > maxLoanRequest) {
            System.out.println("Loan request unsuccessful");
            return;
        }
        currentLoan += amount;
        setIsLoanApproved(false);
        System.out.println("Loan request successful, sent for approval");
    }

    // wont work properly for years > 1
    public void increase_year(int years)
    {
        setMaturityPeriod(getMaturityPeriod() + years);
        int newDeposit = getCurrentDeposit() + Math.round( (getCurrentDeposit()*getInterest()) / 100);
        int loanDeducted = (getCurrentLoan()*loanInterest) / 100;
        newDeposit -= loanDeducted;
        setCurrentDeposit(newDeposit - getCurrentLoan());
    }

    public int getMaturityPeriod() 
    {
        return this.maturityPeriod;
    }

    public void setMaturityPeriod(int maturityPeriod) 
    {
        this.maturityPeriod = maturityPeriod;
    }

    public static void accountCreatedPrompt(String name, String accountType, int initialDeposit)
    {
        System.out.println(accountType + " account for " + name + " Created; initial balance " + initialDeposit + "$");
    }

    public static Accounts create_account(String name, String accountType, int initialDeposit)
    {
        if(accountType.equals("Fixed_deposit")) return Fixed_Deposit.create_account(name, accountType, initialDeposit);
        else if(accountType.equals("Savings")) return Savings.create_account(name, accountType, initialDeposit);
        else if(accountType.equals("Student")) return Student.create_account(name, accountType, initialDeposit);
        else return null;
    }

    public boolean withdraw(int money)
    {
        if(this.getCurrentDeposit() - money < 0)  return false;
        return true;
    }

    public void deposit(int money)
    {
        currentDeposit += money;
        System.out.println(money + "$ deposited; current balance " + currentDeposit);
    }

    public int getCurrentDeposit()
    {
        return currentDeposit + currentLoan;
    }

    public void setCurrentDeposit(int newDeposit)
    {
        this.currentDeposit = newDeposit;
    }

    public void setAccountType(String accountType)
    {   
        this.accountType = accountType;
    }
    public String getAccountType()
    {
        return this.accountType;
    }

    public void setName(String name)
    {
        this.name = name;
    }
    public String getName()
    {
        return this.name;
    }

    public float getInterest()
    {
        return this.interest;
    }
    public void setInterest(float interest)
    {
        this.interest = interest;
    }

    public int getCurrentLoan() {
        return this.currentLoan;
    }

    public void setCurrentLoan(int currentLoan) {
        this.currentLoan = currentLoan;
    }

    public boolean isLoanApproved() {
        return this.isLoanApproved;
    }

    public void setIsLoanApproved(boolean isLoanApproved) {
        if(currentLoan <= 0) isLoanApproved = false;
        this.isLoanApproved = isLoanApproved;
    }

    public int getMaxLoanRequest() {
        return this.maxLoanRequest;
    }

    public void setMaxLoanRequest(int maxLoanRequest) {
        this.maxLoanRequest = maxLoanRequest;
    }
    

    @Override
    public String toString() {
        return "{" +
            " name = '" + getName() + "'" +
            ", accountType = '" + getAccountType() + "'" +
            ", currentDeposit = " + getCurrentDeposit() + "" +
            ", interest = " + getInterest() + "" +
            ", currentLoan = " + getCurrentLoan() + "" +
            ", isLoanApproved = " + isLoanApproved() + "" +
            "}";
    }

}