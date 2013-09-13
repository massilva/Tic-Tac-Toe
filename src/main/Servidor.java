package main;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;

import javax.swing.JOptionPane;

public class Servidor extends Thread {
	
    private static Vector clientes;//Usuários conectados
    private Socket conexao; //Socket do cliente
    private String nomeCliente; 
    private static List nomesClientes = new ArrayList(); //Lista dos nome dos clientes
    
    /**
     * @param socket do cliente
     */
    public Servidor(Socket socket){
        this.conexao = socket;
    }
    
    /**
     * 
     * @param nome do cliente
     * @return TRUE se adicionar o cliente FALSE se o cliente já tiver sido cadastrado
     */
    public boolean addCliente(String nome){
    	
    	if(clientes.size() > 1){
    		return false;
    	}
    	
    	for (int i=0; i< nomesClientes.size(); i++){
         if(nomesClientes.get(i).equals(nome))
           return false;
    	}
       
    	nomesClientes.add(nome);
    	return true;
    }
    
    /**
     * @param oldNome nome do cliente 
     * @return remove da lista os clientes que já deixaram o jogo
     */
    public void remove(String oldNome) {
       for (int i=0; i< nomesClientes.size(); i++){
         if(nomesClientes.get(i).equals(oldNome))
           nomesClientes.remove(oldNome);
       }
    }
    
    public static void main(String args[]) {
        clientes = new Vector();
        try {
            
        	int porta = 5555;
        	ServerSocket server = new ServerSocket(porta); //cria um socket que fica escutando a porta.
            System.out.println("ServidorSocket rodando na porta "+porta);
            
            while (true) {
                /* 
	            * Aguarda algum cliente se conectar.
	            * A execução do servidor fica bloqueada na chamada do método accept da classe ServerSocket até que algum cliente se conecte ao servidor.
	            * Quando cliente se conectar.
	            * O próprio método desbloqueia e retorna com um objeto da classe Socket
	            */
                Socket conexao = server.accept();
                
                Thread t = new Servidor(conexao);
                t.start();
            }
        } catch (IOException e) {
            System.out.println("IOException: " + e);
        }
    }
    
    public void run()
    {
    	/** Simbolos
    	 * 	Iniciar com '#' novo usuário criado
    	 * 	Iniciar com '@' usuário saiu
    	 *  Iniciar com '!' erro
    	 *  Iniciar com '&' diz quem está online
    	 */
        try {
            //Fluxo de comunicação que vem do cliente
            BufferedReader entrada =
                new BufferedReader(new InputStreamReader(this.conexao.getInputStream()));

            PrintStream saida = new PrintStream(this.conexao.getOutputStream());
            
            this.nomeCliente = entrada.readLine();//pegando dados enviando pelo usuario 
            
            if(!addCliente(this.nomeCliente)){
              saida.println("!Este nome ja existe! Conecte novamente com outro Nome.");
              this.conexao.close();
              return;
            } else {
               System.out.println(this.nomeCliente + " : Conectado ao Servidor!");
               sendPeopleOnline(saida,"&"); //enviando quem está online para quem acabou de entrar
               sendToAll(saida,"#"+this.nomeCliente); //Envia Novo usuário para quem está online
            }
            
            if(this.nomeCliente == null){
                return;
            }
            
            clientes.add(saida); //adiciona os dados de saida do cliente
            String msg = entrada.readLine(); //recebe a mensagem do cliente
            /*
            * Verificar se msg recebida é null.
            * Se sim encerra a conexão.
            * Se não mostra a troca de mensagens entre os clientes
            */
            while (msg != null && !(msg.trim().equals("")))
            {
            	sendToAll(saida,msg);
            	msg = entrada.readLine();
            }
            
            System.out.println(this.nomeCliente + " saiu do jogo!");
            
            sendToAll(saida,"@");//informa ao usuário conectado que um usuário saiu. 
            remove(this.nomeCliente);
            clientes.remove(saida);
            this.conexao.close(); //fecha conexão deste usuário
            
        } catch (IOException e) {
            System.out.println("Falha na Conexao... .. ."+" IOException: " + e);
        }
    }
    
    /**
     * @param saida PrintStream usado como saida
     * @param msg Mensagem a ser enviada
     * @throws IOException 
     */
    public void sendToAll(PrintStream saida, String msg) throws IOException {
        Enumeration e = clientes.elements();
        while (e.hasMoreElements()) {
            
        	PrintStream c = (PrintStream) e.nextElement();//obtém o fluxo de saída de um dos clientes
            
        	// envia para todos, menos para o próprio usuário
            if (c != saida) {
                c.println(msg);
            }
        }
    }
    
    /**
     * @param saida PrintStream usado como saida
     * @param msg Mensagem a ser enviada
     * @throws IOException
     */
    public void sendPeopleOnline(PrintStream saida, String msg) throws IOException {
    	if(clientes.size() != 0){
	    	PrintStream c = (PrintStream) saida;
	        c.println(msg+nomesClientes.get(0));
    	}
    }
    
    public int get(List lista, String nome){
    	Iterator it = lista.iterator();
    	int i = 0;
    	while (it.hasNext()) {
			String nm = (String) it.next();
			if(nome.equals(nm)){
				return i;
			}
		}
    	return -1;
    }
}