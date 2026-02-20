# HabitFlow

HabitFlow é um aplicativo Flutter focado em organização pessoal, rotinas e controle de hábitos.

O objetivo é fornecer um planner moderno com acompanhamento visual de desempenho, calendário inteligente e sistema de metas.

---

## 🚀 Funcionalidades Planejadas

### 📅 Planner
- Calendário superior com:
    - Dia numeral atual
    - Nome do dia em inglês (Sun, Mon, Tue...)
- Lista de tarefas
- Criação rápida de tarefa
- Organização por categorias
- Adição rápida após ligação

### 🔁 Hábitos
- Controle semanal visual:
    - 🟢 Verde → hábito cumprido
    - ⚪ Cinza claro → não cumprido
    - ⚫ Cinza escuro → não programado
- Percentual de assertividade
- Visualização mensal detalhada
- Sistema de streak
- Timer para auxiliar cumprimento

---

## 🏗 Estrutura do Projeto
habitflow/
    └── lib/
        ├── main.dart
        ├── screens/
        │    ├── home_screen.dart
        │    └── habits_screen.dart
        ├── widgets/
        │    ├── calendar_header.dart
        │    └── habit_week_row.dart
        ├── models/
        │    └── habit.dart


Responsabilidade:

- Inicializa o app

- Define tema (Material 3)

- Controla navegação inferior (Planner / Habits)

O que já faz:

- Usa PlannerApp

- Tem MainNavigation

Alterna entre:

- HomeScreen

- HabitsScreen

- BottomNavigation funcional

⃣ screens/home_screen.dart


Responsabilidade:

- Tela principal do Planner

- O que já faz:

- Mostra AppBar "Today"

- Exibe CalendarHeader

- Tem botão flutuante para futura criação de tarefa

- Estrutura pronta para lista de tarefas

⚠ Ainda não tem CRUD de tarefas.

3️⃣ widgets/calendar_header.dart

Responsabilidade:

- Exibir data atual no topo

O que já faz:

- Mostra nome do dia em inglês (Sun, Mon...)

- Mostra número do dia

- Usa intl para formatação

Exemplo:

- Sun 24
4️⃣ screens/habits_screen.dart

- Responsabilidade:

- Tela de controle de hábitos

O que já faz:

✔ Hábito exemplo: "Não beber"
✔ Semana visual com 7 dias
✔ Estados:

Verde → Cumprido

Cinza claro → Não cumprido

Cinza escuro → Não programado


✔ Clique alterna estado:

null → true → false → null

✔ Cálculo automático de assertividade (%)
✔ Destaca dia atual com borda azul
✔ Abre calendário mensal com long press

5️⃣ widgets/habit_week_row.dart

Responsabilidade:

Renderizar a linha semanal visual

O que já faz:

- Recebe weekData

- Recebe onTap

- Recebe currentDayIndex

- Renderiza 7 quadrados

- Detecta clique individual

- Destaca o dia atual

- É um componente isolado e reutilizável.

6️⃣ models/habit.dart

Responsabilidade:

- Modelo de dados para hábito

O que já faz:

- Define estrutura:

    class Habit {
        final String name;
        final Map<DateTime, bool?> completion;
    }

---

## 🛠 Tecnologias

- Flutter
- Dart
- Material 3
- intl (formatação de datas)


👨‍💻 Autor

Manoel Jorge

📄 Licença

Projeto para fins educacionais.


---

Depois faça commit:

```bash
git add README.md
git commit -m "docs: add project README"