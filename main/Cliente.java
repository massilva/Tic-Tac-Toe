import javax.swing.JOptionPane;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.net.Socket;

public class Cliente extends Thread {
  
    // parte que controla a recepção de mensagens do cliente
    private Socket conexao;
    private String msg;
    private String nome;
    private Cliente jogador2;//jogador contra
    private String nJ2 = "Jogador 2";
    
    public Cliente(String nome){
        this.nome = nome;
    }
    
    //usando quando conecta-se ao servidor
    public Cliente(Socket socket,String nome) {
        this.conexao = socket;
        this.nome = nome;
        this.jogador2 = new Cliente(nJ2);
    }
    
    public void run()
    {
        try {

            //recebe mensagens de outro cliente através do servidor
            BufferedReader entrada = 
                new BufferedReader(new InputStreamReader(this.conexao.getInputStream()));
            
            while (true)
            {
               this.msg = entrada.readLine(); //msg vinda do servidor

               //se a mensagem não contiver dados, cai no break e encerra a conexao
               if (msg == null){
                    System.out.println("Conexão encerrada!");
                    System.exit(0);
               }

               System.out.println();
               
               /* Simbolos
               *  '#' => Novo Usuário
               *  '@' => Usuário saiu do Jogo!
               */
               
               if(msg.startsWith("#")||msg.startsWith("&"))
               { 
                 String nm = msg.substring(1,msg.length());
                 this.jogador2 = new Cliente(nm);
               }
               
               if(msg.equals("@")){
                 JOptionPane.showMessageDialog(null,this.jogador2.getNome()+" saiu do jogo!");
                 this.jogador2 = new Cliente(nJ2);  
               }
               
               System.out.println("S: "+msg);
            }
        } catch (IOException e) {
            System.out.println("Ocorreu uma Falha... .. ." +
                " IOException: " + e);
        }
    }
    
    public String getMsg(){
      return this.msg;
    }

    public String getNome(){
      return this.nome;
    }
    
    public Cliente getContra(){
      return jogador2; 
    }
    
}
