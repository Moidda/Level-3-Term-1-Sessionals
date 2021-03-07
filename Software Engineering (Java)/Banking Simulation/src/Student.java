public class Student extends Accounts {
    
    private static float accountInterest = 5;
    private int maxWithdraw = 10000;
    private int accountMaxLoan = 1000;

    Student(String name, String accountType, int initialDeposit)
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
        if(money > maxWithdraw) {
            System.out.println("Invalid transaction; current balance " + getCurrentDeposit() + "$");
            System.out.println("Cannot withdraw more than " + maxWithdraw + "$");
            return false;
        }
        this.setCurrentDeposit(this.getCurrentDeposit() - money);
        System.out.println("Withdraw successful; current balance " + getCurrentDeposit() + "$");
        return true;
    }

    public static Student create_account(String name, String accountType, int initialDeposit)
    {
        Student student = new Student(name, accountType, initialDeposit);
        accountCreatedPrompt(name, accountType, initialDeposit);
        return student;
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
