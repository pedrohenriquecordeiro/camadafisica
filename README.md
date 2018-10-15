# Camada Física

>- **Camada Fisica:** https://github.com/pedrohenriquecordeiro/camadafisica
>- **Camada Rede:** 
>- **Camada Transporte:** 
>- **Camada Aplicação:** https://github.com/thiagofigcosta/camadaaplicacao

>- **Todas as camadas:** https://github.com/thiagofigcosta/camadas-rede

Implementacao da Camada Física do Trabalho Prático de Redes 1 - CEFET-MG

  - Integrantes do grupo:
    + Marcos Henriques
    + Pedro Cordeiro
    + Bernard
    + Thiago

O Enunciado está neste __[link.](https://docs.google.com/document/d/1O3cNM0T6gFNz9PeMYcnzbmBzEe8J7k34DaefJDSsv4A/edit)__
O relatório a ser preenchido está neste __[link.](https://docs.google.com/document/d/13nwTYGULBXMB81_vo7_yVNxVpZ-V0RNZ0xpnynoLuqA/edit?usp=sharing)__

___

---

***

## Relação de Linguagens Escolhidas 

| Camada | Linguagem |
| ------ | ----------- |
| fisica | perl |
| aplicação | python |
| transporte | javascript |
| rede | php |
___


## Uso do Código


### Camada Física
Instale a linguagem `perl`

Instale os pacotes necessários, através dos comandos:

    cpan
    install IO::Socket::INET
    install Time::HiRes
    install Net::Address::IP::Local


Na máquina que será o servidor, rode o script "server.pl"

```
perl server.pl
```

Na máquina que será o cliente, rode o script "client.pl"

```
perl client.pl
```

### Camada de aplicação
Instale a linguagem `python` (versão 2.7) e os pacotes necessários, através dos comandos:

    sudo apt-get install python
	sudo apt-get install python-pip
	sudo apt-get install python-tk
	sudo apt-get install python-xlib
	sudo apt-get install scrot
	pip install -r requirements.txt


Na máquina que será controlada, rode o script "controlled.py"

```
python controlled.py
```

Na máquina que irá controlar, rode o script "controller.py"

```
python controller.py
```




