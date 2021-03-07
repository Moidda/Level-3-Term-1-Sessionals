import java.util.ArrayList;

public class MD extends Employee {
    
    public void changeInterestRate(String accountType, float newInterest, ArrayList<Accounts> accounts)
    {
        if(accountType.equals("Student")) {
            Student.setAccountInterest(newInterest);
        }
        else if(accountType.equals("Savings")) {
            Savings.setAccountInterest(newInterest);
        }
        else if(accountType.equals("Fixed_deposit")) {
            Fixed_Deposit.setAccountInterest(newInterest);
        }
        for(int i = 0; i < accounts.size(); i++) {
            if(accounts.get(i).getAccountType().equals(accountType)) {
                accounts.get(i).setInterest(newInterest);
            }
        }
    }

    public void seeInternalFund(Bank bank)
    {
        System.out.println("Internal Fund " + bank.getFund() + "$");
    }
}
