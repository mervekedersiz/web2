class SoapBankService {
    public String getBalanceXml() {
        return "<bakiye>5000</bakiye>";
    }
    public String registerXml(String ad) {
        return "<kullanici><id>101</id></kullanici>";
    }
    public String loginXml() {
        return "<giris><islem>Giris Yapildi</islem></giris>";
    }
}

class BankXmlAdapter {
    private final SoapBankService soap = new SoapBankService();

    public String getBalance() {
        return "{\"balance\": " + soap.getBalanceXml().replaceAll("\\D+", "") + "}";
    }

    public String register(String ad) {
        return "{\"name\": \"" + ad + "\", \"id\": " + soap.registerXml(ad).replaceAll("\\D+", "") + "}";
    }

    public String login() {
        String islem = soap.loginXml().replace("<giris><islem>", "").replace("</islem></giris>", "");
        return "{\"status\": \"ok\", \"lastAction\": \"" + islem + "\"}";
    }
}

public class main {
    public static void main(String[] args) {
        BankXmlAdapter adapter = new BankXmlAdapter();

        System.out.println(adapter.getBalance());
        System.out.println(adapter.register("Merve"));
        System.out.println(adapter.login());
    }
}