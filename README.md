# Minimal memory OS 

<p align="center">
  <img src="https://github.com/user-attachments/assets/a720680f-cfe4-40e0-8fe8-83ec0ccf0f24" alt="Minimal memory OS  logo" width="150" height="150" style="border-radius: 50%;">
  <br>
  <a href="https://github.com/infernosalex/memory-manager-os">
    <img src="https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white" alt="GitHub">
  </a>
</p>

This project is a minimal memory OS that can be run on a x86 machine. It is my HW for the [ASC course at the University of Bucharest](https://cs.unibuc.ro/~crusu/asc/index.html).
The link to the HW is [here](https://cs.unibuc.ro/~crusu/asc/Arhitectura%20Sistemelor%20de%20Calcul%20(ASC)%20-%20Tema%20Laborator%202024.pdf). 

## How to run the project

To run the project you need to have the following tools installed:
```bash
sudo apt-get install g++-multilib
```

To compile the project you need to run the following command:
```bash
make vector/matrix
```
where `vector/matrix` is the name of the program you want to run.

For example, to run the vector program you need to run the following command:
```bash
make vector
```
