# 🏗️ Inverted Pendulum — Output‑Feedback Control with a Full‑State Observer

> A two‑link inverted pendulum is held **upright** using a **state‑feedback controller** that acts on a **state estimate** from a full‑state observer. The observer reconstructs the **unmeasured angular rates** so the controller can behave as if every state were measured.

---

## 🎬 Demo (mp4)
<div align="center">
  
https://github.com/user-attachments/assets/7126a784-6d52-4681-a8f2-ded9851cf9db
  
</div>
---

## 🔎 What this project is (plain English)

- The rig has two joint angles, $q_1$ (base) and $q_2$ (link). Only **angles** are measured. The **angular rates** $\dot q_1,\dot q_2$ are not.  
- The controller needs **all four**: $(q_1,q_2,\dot q_1,\dot q_2)$.  
- A **full‑state observer** estimates the missing rates from the model + sensor readings. The controller then applies a motor command using the **estimate** instead of the true state.  
- The design and tuning were done in **MATLAB/Simulink** and verified on hardware.

---

## 🖼️ Mechanism (schematic)

<div align="center">
  <img width="489" height="387" alt="Inverted pendulum schematic" src="https://github.com/user-attachments/assets/f4cb9196-2bcc-4371-b61f-13483633afde" />
  <br/>
  <sub><b>Fig S — Mechanism.</b> Rotary base (joint 1) moves the pendulum link (joint 2). Angles are measured; rates are estimated.</sub>
</div>

---

## 🧠 Big idea → then the math

### The big idea
1) **Predict.** A copy of the linearized model predicts how the state should evolve.  
2) **Correct.** Compare the **predicted angles** to the **measured angles**; use the difference to correct the prediction.  
3) **Control.** Feed the **corrected estimate** into a state‑feedback law that pushes the link back upright.

### The math ladder (simple → formal)

**1) Linear model near upright**

$$
\dot x = A x + B u, \qquad y = C x
$$

with

$$
x = \begin{bmatrix} q_1 & q_2 & \dot q_1 & \dot q_2 \end{bmatrix}^\top, \qquad
y = \begin{bmatrix} q_1 & q_2 \end{bmatrix}^\top .
$$

**2) State‑feedback (if the full state were available)**

$$
u = -K x \;\Rightarrow\; \dot x = (A - B K) x .
$$

The matrix $K$ is chosen so the eigenvalues of $(A-BK)$ give stable, well‑damped motion. The pre‑obtained targets were

$$
\{-10 \pm 10j,\ -15,\ -18\}.
$$

**3) Full‑state observer (to reconstruct the missing rates)**

$$
\dot{\hat x} = A \hat x + B u + L\,\big(y - C \hat x\big) .
$$

The correction $L\,(y - C\hat x)$ pulls the estimate toward the measured angles when prediction and measurement disagree.

**4) Estimation error dynamics (why it works)**

Let $\tilde x = x - \hat x$. Then

$$
\dot{\tilde x} = (A - L C)\,\tilde x .
$$

Placing the eigenvalues of $(A-LC)$ **faster** (more negative) than the controller’s makes the error die out quickly, so $\hat x \approx x$ during control.

**5) Output‑feedback loop (what actually runs)**

$$
u = -K\,\hat x .
$$

With a stable $(A-BK)$ and a stable $(A-LC)$, the combined loop is stable (separation principle).

---

## 🛠️ What was actually implemented

1. **Build $A,B,C$.** Linearize the pendulum model about upright and identify parameters for the specific rig.  
2. **Choose $K$.** Use pole placement for the pre‑obtained targets $\{-10 \pm 10j,\ -15,\ -18\}$ (good damping + responsiveness).  
3. **Choose $L$.** Start with observer poles ≈ **15× faster** than the controller poles (a good balance of speed vs. noise on hardware).  
4. **Wire it up in Simulink.** Observer as a State‑Space block; controller applies $u=-K\hat x$; sampling at **1 kHz**.

---

## 🧪 Results

### Simulink model (structure)

<div align="center">
  <img width="1364" height="598" alt="Simulink output-feedback model" src="https://github.com/user-attachments/assets/3a961c7f-32f5-4fa5-b72f-3da6a6880622" />
  <br/>
  <sub><b>Fig 4 — Output‑feedback implementation in Simulink.</b> Observer block computes $\hat x$ from $u$ and $y$; controller applies $u=-K\hat x$.</sub>
</div>

### Hardware run (tuning the observer)

- With **$20\times$ scaling**, the rig stabilized but showed **oscillation** and persistent input activity.  
- Reducing to **$15\times$** produced **smoother** behavior and long stretches of **near‑zero control effort** at the setpoint.

<div align="center">
  <img width="792" height="625" alt="Angles and input with 15x observer" src="https://github.com/user-attachments/assets/b8629492-9a30-47a2-9251-c27f8793486b" />
  <br/>
  <sub><b>Fig 6 — Physical results.</b> Joint angles (top) and motor voltage (bottom) with observer poles at ~<code>15×</code> the controller poles.</sub>
</div>

---

## 📌 Practical notes

- **Observer speed vs. noise.** Faster observers track better but amplify sensor noise; ~**15×** was the sweet spot here.  
- **Actuator limits & friction.** Differences vs. simulation are consistent with voltage limits and unmodeled Coulomb friction.  
- **Units.** Keep everything in **radians** internally; only convert for plotting.

---

## 🗂️ Repo pointers

- `phase4_lab_Students.slx`, `Phase4_Model_Student.slx` — Simulink models (implementation and plant).  
- `phase4_script_Students.txt` — MATLAB script for $K$ and $L$ design + plots.  
- `*_actual-*.mat` — logged hardware runs used to produce Fig 6.

---

## 🧠 Glossary

**State feedback** — a control law $u=-Kx$ that uses the full state.  
**Full‑state observer** — dynamic estimator $\dot{\hat x}=A\hat x+Bu+L(y-C\hat x)$ that reconstructs unmeasured states.  
**Pole placement** — choosing eigenvalues of $(A-BK)$ or $(A-LC)$ to shape dynamics.  
**Separation principle** — design $K$ and $L$ independently; if both loops are stable, the combined loop is stable.

---

## License

MIT — see `LICENSE`.

