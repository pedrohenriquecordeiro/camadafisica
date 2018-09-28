# Camada Física

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


