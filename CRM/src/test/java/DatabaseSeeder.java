
import util.PasswordUtil;

public class DatabaseSeeder {

    public static void main(String[] args) throws Exception {
        String hash = PasswordUtil.hashPassword("123456");
        System.out.println("HASH: " + hash);
    }
}
