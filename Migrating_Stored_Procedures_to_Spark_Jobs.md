# Migrating Stored Procedures into Spark Jobs  

This document explains how to convert SQL stored procedures (SPs) into Spark jobs in a clear and systematic way.  

The goal is to keep the **business logic**, **data flow**, and **correct results**—not to convert the code line by line.

---

## 1. The Fundamental Mental Shift

### Stored Procedure World
- Step-by-step, procedural logic  
- Stateful (tables change after each step)  
- Heavy use of control flow (IF, WHILE, transactions)  
- Database optimizer hides execution details  

### Spark World
- Declarative transformations on datasets  
- Immutable DataFrames (no in-place updates)  
- Clear and visible data flow (DAG)  
- You are responsible for performance and correctness  

**Key rule**  
> A stored procedure controls steps and table changes.  
> A Spark job is a pipeline (DAG) of transformations with clear inputs and outputs.

Trying to convert SP code line by line usually leads to bad Spark code.

---

## 2. Phase 0: Normalize the Stored Procedure (No Spark Yet)

Before writing any Spark code, first understand the stored procedure.

From the SP, identify:

- Inputs  
- Source tables  
- Target tables  
- Temporary tables  
- Control flow  
- Transactions  
- Error handling & logging  

Redraw the stored procedure as a **logical DAG**:

Inputs → Stage 1 → Stage 2 → Stage 3 → Writes  

If you cannot draw this flow clearly, you do not fully understand the SP.

---

## 3. Phase 1: Concept Mapping (SP → Spark)

### Parameters  
Stored procedure parameters become fixed inputs to the Spark job.

---

### Source Tables  
Read tables once and reuse DataFrames.  
Avoid reading the same table multiple times.

---

### Temporary Tables  
Temporary tables become intermediate DataFrames.  
Each step creates a new DataFrame—no mutation.

---

### INSERT / UPDATE / DELETE  
Spark does not update rows directly. It replaces data.

- INSERT → write a DataFrame  
- UPDATE → join + recompute columns + overwrite  
- DELETE → anti-join  

---

### IF / ELSE Logic  
- Job-level decisions → Python `if` statements  
- Row-level decisions → `when / otherwise`  

---

### WHILE Loops  
Loops are a warning sign.  

Redesign the logic using:
- Window functions  
- Aggregations  

Do not translate loops directly.

---

### Transactions  
Spark does not support multi-table transactions.

Design for:
- Idempotent jobs  
- Atomic writes (overwrite, swap, staging tables)  

---

### Error Handling  
Use:
- `try / except` in the driver  
- Explicit error logging tables or files  

---

## 4. Phase 2: Spark Job Skeleton

```python
def load_sources(spark):
    ...

def transform_stage_1(inputs):
    ...

def transform_stage_2(stage1_df):
    ...

def write_targets(final_df):
    ...

def main(args):
    sources = load_sources(spark)
    stage1 = transform_stage_1(sources)
    stage2 = transform_stage_2(stage1)
    write_targets(stage2)
```

Transformations are separated into stages.  
All writes happen at the end.

---

## 5. Phase 3: Validation Strategy

Validate each step, not just the final output:

- Row counts  
- Join results  
- Null values  
- Aggregation results  
- Idempotency (running the job twice gives the same result)  

---

## 6. Common Migration Traps

- Treating Spark like a database  
- Converting loops directly  
- Overusing `collect()`  
- Assuming row order  
- Assuming updates work like SQL  

---

## 7. Practice Loop

1. Break the SP into steps  
2. Draw the DAG  
3. Implement transformations  
4. Add writes at the end  
5. Validate every stage  

---

## 8. End State

Stored procedures become clear data pipelines.  
Spark becomes a system for running business logic at scale.  
Migration becomes predictable and manageable.
