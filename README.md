# 🏗️ Inverted Pendulum — Output‑Feedback Control with a Full‑State Observer

> Stabilizing a **double‑jointed inverted pendulum** at the **upright** equilibrium by combining a **state‑feedback controller** with a **full‑state observer** that estimates the unmeasured joint velocities from input and angle measurements.

---

## 🎬 Demo (mp4)

<video src="https://github.com/user-attachments/assets/7126a784-6d52-4681-a8f2-ded9851cf9db" controls muted width="600" style="border: none; outline: none;"></video>

---

## 🔎 What this project is

- **Goal.** Keep a two‑link pendulum **upright** using **output‑feedback**: a state‑feedback law $u=-K\hat x$ driven by a **state estimate** $\hat x$.  
- **Why an observer?** Only the **joint angles** are measured; the **joint angular velocities** are not. A **full‑state observer** reconstructs the missing states from the sensor outputs and the applied input in real time, then the controller uses $\hat x$ as if it were $x$.  
- **Validation.** Designed and tuned in **MATLAB/Simulink**, then run on the physical rig; the upright pose holds with small oscillations once the observer poles are tuned.

---

## 🖼️ System at a glance (schematic)

<div align="center">
  <img width="489" height="387" alt="SCR-20250929-oggz" src="https://github.com/user-attachments/assets/f4cb9196-2bcc-4371-b61f-13483633afde" />
  <br/>
  <sub><b>Fig S — Mechanism.</b> Rotary base (joint 1) actuates a pendulum link (joint 2). Angles are measured; velocities are estimated.</sub>
</div>


---

## 🧠 Intuition before math

1) **Measured vs. needed.** Control needs the **full state** $(q_1,q_2,\dot q_1,\dot q_2)$, but only $(q_1,q_2)$ are measured.  
2) **Observer idea.** Run a **copy** of the linear model inside the controller and continually **correct** it with the difference between what the model predicts and what the sensors report.  
3) **Tuning idea.** Make the observer **faster** than the controller so its estimates “catch up” quickly but not so fast that it amplifies noise.

---

## 🧮 Minimal math (supporting the story)

**Linear model near upright.** Around the upright equilibrium $(q_2=\pi)$ the nonlinear dynamics are linearized to
$$\dot x = A x + B u,\qquad y=Cx,$$
with $x=[\,q_1,\ q_2,\ \dot q_1,\ \dot q_2\,]^T$ and $y=[\,q_1,\ q_2\,]^T$. (Matrices are computed from identified parameters; see report.)

**State‑feedback refresher.**
$$u = -Kx\quad\Rightarrow\quad \dot x=(A-BK)x.$$
With controllability, poles of $A-BK$ are placed by design (canonical‑form recipe / `place`).

**Full‑state observer.**
$$\dot{\hat x} = A\hat x + Bu + L\big(y-C\hat x\big)=(A-LC)\hat x + Bu + Ly.$$
The **estimation error** $\tilde x=x-\hat x$ obeys
$$\dot{\tilde x}=(A-LC)\tilde x,$$
so choosing the **observer poles** (eigenvalues of $A-LC$) **left of** the controller poles makes the error die out quickly. (Implemented with `L = place(A',C',p_e)^\top`.)

**Output‑feedback loop.**
$$u=-K\hat x\quad\text{with}\quad \dot{\hat x} = (A-LC)\hat x + Bu + Ly.$$
This realizes full‑state control using only measured angles.

---

## 🛠️ What was actually done

1. **Linearization & parameters.** Build $A,B,C$ about the upright equilibrium using the provided parameter set (“machine 5”).  
2. **Controller $K$ via pole placement.** Desired closed‑loop poles around $\{-10\!\pm\!10j,\,-15,\,-18\}$ were used (Phase 3 carry‑over).  
3. **Observer $L$ via faster poles.** Start with observer poles scaled by $5\times$–$20\times$ the controller poles; refine on hardware to balance speed vs. noise sensitivity.  
4. **Implementation.** Integrate the observer as a **State‑Space** block in Simulink and close the loop with $u=-K\hat x$. (Sampling in the reference scripts is $T_s=1$ ms.)

---

## 🧪 Results (simulation → hardware)

### Simulink model (structure)

<div align="center">
  <img width="1364" height="598" alt="SCR-20250929-oijf" src="https://github.com/user-attachments/assets/3a961c7f-32f5-4fa5-b72f-3da6a6880622" />
  <br/>
  <sub><b>Fig 4 — Output‑feedback implementation in Simulink.</b> Observer block computes $\hat x$ from $u$ and $y$; controller applies $u=-K\hat x$.</sub>
</div>


### Hardware run (tuning the observer)

- With **$20\times$ scaling**, the rig stabilized but showed **oscillations** and persistent input activity.
- Reducing to **$15\times$** yielded **smoother** behavior and periods of **near‑zero control effort** at the setpoint.

<div align="center">
  <img width="792" height="625" alt="SCR-20250929-oiku" src="https://github.com/user-attachments/assets/b8629492-9a30-47a2-9251-c27f8793486b" />
  <br/>
  <sub><b>Fig 6 — Physical results.</b> Joint angles (top) and motor voltage (bottom) with observer poles at roughly <code>15×</code> the controller poles.</sub>
</div>


---

## 📌 Practical notes

- **Pick observer poles thoughtfully.** Faster poles improve tracking but **amplify noise**; hardware favored $\sim\!15\times$ over $20\times$.  
- **Saturation & friction matter.** Minor differences vs. simulation are consistent with actuator limits and unmodeled Coulomb friction.  
- **Sampling and units.** Keep radians throughout; logs were captured at **1 kHz** sample rate.

---

## 🗂️ Repo pointers (for context)

- `phase4_lab_Students.slx`, `Phase4_Model_Student.slx` — Simulink models used for simulation and deployment.  
- `phase4_script_Students.txt` — MATLAB script for pole placement, observer design, and plotting.  
- `*_actual-*.mat` — logs of **angles** and **input voltage** from hardware runs (used to produce Fig 6).

---

## 🧠 Glossary

**Full‑state observer** — dynamic estimator that reconstructs $x$ from $u$ and $y$.  
**Pole placement** — choosing eigenvalues of $A-BK$ (controller) or $A-LC$ (observer).  
**Observability** — ability to infer $x$ from $y$ (rank of the observability matrix).  
**Output‑feedback** — control using measured outputs + estimated states ($u=-K\hat x$).

---

## License

MIT — see `LICENSE`.
