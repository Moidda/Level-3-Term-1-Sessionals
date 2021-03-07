import java.util.ArrayList;

public class Employee {
    
    public void lookup(Accounts user)
    {
        if(user == null) return;
        System.out.println(user.getName() + "'s current balance " + user.getCurrentDeposit() + "$");
    }

    public void approveLoan(Accounts user)
    {
        System.out.println("Loan for " + user.getName() + " approved");
        user.setIsLoanApproved(true);
    }

    public void changeInterestRate(String accountType, float newInterest, ArrayList<Accounts> accounts)
    {
        System.out.println("You don't have permission for this operation");
    }

    public void seeInternalFund(Bank bank)
    {
        System.out.println("You don't have permission for this operation");
    }
}
