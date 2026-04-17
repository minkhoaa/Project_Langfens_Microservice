from locust import HttpUser, task, between


class WritingUser(HttpUser):
    wait_time = between(1, 3)

    @task(3)
    def compare_essay(self):
        self.client.post("/v1/writing/compare", json={
            "essay_text": "Some people believe that technology has made our lives easier. "
                          "However, others argue that it has created new problems. " * 10,
            "topic": "technology and modern life",
            "task_type": "TASK_2",
            "student_band": 6.5,
        })

    @task(1)
    def grammar_explain(self):
        self.client.post("/v1/grammar/explain", json={
            "error_text": "He go to school every day.",
            "context": "He go to school every day and study hard.",
            "correct_form": "He goes to school every day.",
        })
