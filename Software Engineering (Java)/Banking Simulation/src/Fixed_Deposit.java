public class Fixed_Deposit extends Accounts {

    private static float accountInterest = 15;
    private int minDeposit = 50000;
    private int accountMaxLoan = 100000;

    Fixed_Deposit(String name, String accountType, int initialDeposit)
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
        if(this.getMaturityPeriod() < 1) {
            System.out.println("Invalid transaction; maturity period " + getMaturityPeriod() + " years");
            return false;
        }
        this.setCurrentDeposit(this.getCurrentDeposit() - money);
        System.out.println("Withdraw successful; current balance " + getCurrentDeposit() + "$");
        return true;
    }

    public static Fixed_Deposit create_account(String name, String accountType, int initialDeposit)
    {
        if(initialDeposit < 100000){
            System.out.println("Initial deposit must be atleast 100,000");
            return null;
        }

        Fixed_Deposit fixed_Deposit = new Fixed_Deposit(name, accountType, initialDeposit);
        accountCreatedPrompt(name, accountType, initialDeposit);
        return fixed_Deposit;
    }

    public void deposit(int money)
    {
        if(money < minDeposit) {
            System.out.println("Deposit amount must be atleast " + minDeposit + "$");
            return;
        }
        super.deposit(money);
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
