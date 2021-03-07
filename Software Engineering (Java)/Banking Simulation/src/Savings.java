public class Savings extends Accounts {

    private static float accountInterest = 10;
    private int withdrawLimit = 1000;
    private int accountMaxLoan = 10000;

    Savings(String name, String accountType, int initialDeposit)
    {
        super(name, accountType, initialDeposit);
        setInterest(accountInterest);
        setMaxLoanRequest(accountMaxLoan);
    }

    public boolean withdraw(int money)
    {
        if(!super.withdraw(money)) {
            System.out.println("Invalid transaction; current balance " + getCurrentDeposit() + "$");
            return false;
        }
        if(this.getCurrentDeposit() < withdrawLimit) {
            System.out.println("Invalid transaction; current balance " + getCurrentDeposit() + "$");
            return false;
        }
        int remainingDeposit = this.getCurrentDeposit() - money;
        if(remainingDeposit < withdrawLimit) {
            int maxWithdraw = this.getCurrentDeposit() - withdrawLimit;
            System.out.println("Cannot withdraw more than " + maxWithdraw);
            return false;
        }
        this.setCurrentDeposit(this.getCurrentDeposit() - money);
        System.out.println("Withdraw successful; current balance " + getCurrentDeposit() + "$");
        return true;
    }

    public static Savings create_account(String name, String accountType, int initialDeposit)
    {
        Savings savings = new Savings(name, accountType, initialDeposit);
        accountCreatedPrompt(name, accountType, initialDeposit);
        return savings;
    }

    public static void setAccountInterest(float interest)
    {
        accountInterest = interest;
    }
    public static float getAccountInterest()
    {
        return accountInterest;
    }
}
