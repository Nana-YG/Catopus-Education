package org.catopus.Contentserver.Controller;

import org.catopus.Contentserver.Model.UserProgress;
import org.catopus.Contentserver.Model.ClassProgress;
import org.catopus.Contentserver.Repository.ProgressRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/progress")
public class ProgressController {

    @Autowired
    private ProgressRepository repository;

    // ========== GET 用户进度 ==========
    @GetMapping("/{username}")
    public ResponseEntity<UserProgress> getProgress(
            @PathVariable String username,
            @RequestHeader("username") String headerUsername) {

        // 1. 检查 URL 中的 username 是否与 Header 中一致（防止用户越权）
        if (!username.equals(headerUsername)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        // 2. 查询 MongoDB 是否已有该用户的记录
        Optional<UserProgress> userProgressOptional = repository.findById(username);

        // 3. 若找到，直接返回
        if (userProgressOptional.isPresent()) {
            UserProgress existingProgress = userProgressOptional.get();
            return ResponseEntity.ok(existingProgress);
        }

        // 4. 若未找到，构造新用户的空记录
        UserProgress newProgress = new UserProgress();
        newProgress.setUsername(username);

        // 初始化一个空的 classes 字段（无课程）
        Map<String, ClassProgress> emptyClasses = new HashMap<>();
        newProgress.setClasses(emptyClasses);

        // 5. 存入数据库
        repository.save(newProgress);

        // 6. 返回新建数据
        return ResponseEntity.ok(newProgress);
    }

    @GetMapping("/{username}/classes/{classId}")
    public ResponseEntity<ClassProgress> getProgress(
            @PathVariable String username,
            @PathVariable String classId,
            @RequestHeader("username") String headerUsername) {

        // 1. 检查权限
        if (!username.equals(headerUsername)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        // 2. 查找用户
        Optional<UserProgress> userProgressOptional = repository.findById(username);

        UserProgress userProgress;
        if (userProgressOptional.isPresent()) {
            userProgress = userProgressOptional.get();
        } else {
            // 3. 新建用户空记录
            userProgress = new UserProgress();
            userProgress.setUsername(username);
            userProgress.setClasses(new HashMap<>());
            repository.save(userProgress);
        }

        // 4. 返回该课程的进度（如果还没有课程数据，返回空 ClassProgress）
        ClassProgress classProgress = userProgress.getClasses().getOrDefault(classId, new ClassProgress());
        return ResponseEntity.ok(classProgress);
    }


    // ========== PUT 更新某个任务完成状态 ==========
    @PutMapping("/{username}/classes/{classId}/tasks/{taskId}")
    public ResponseEntity<?> updateTaskProgress(
            @PathVariable String username,
            @PathVariable String classId,
            @PathVariable String taskId,
            @RequestHeader("username") String headerUsername,
            @RequestBody TaskUpdatePayload payload) {

        // 1. 检查 URL 中的 username 是否与 Header 中一致
        if (!username.equals(headerUsername)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        // 2. 查询用户是否存在
        Optional<UserProgress> progressOptional = repository.findById(username);

        UserProgress progress;
        if (progressOptional.isPresent()) {
            progress = progressOptional.get();
        } else {
            // 若用户不存在，则新建一个空结构
            progress = new UserProgress();
            progress.setUsername(username);
            progress.setClasses(new HashMap<>());
        }

        // 3. 获取或创建 classProgress（课程进度）
        Map<String, ClassProgress> classes = progress.getClasses();
        ClassProgress classProgress;

        if (classes.containsKey(classId)) {
            classProgress = classes.get(classId);
        } else {
            classProgress = new ClassProgress();
            classProgress.setSubject(payload.getSubject());  // 初始化课程学科
            classProgress.setTasks(new HashMap<>());
            classes.put(classId, classProgress);
        }

        // 4. 更新任务完成状态
        classProgress.getTasks().put(taskId, payload.getCompleted());

        // 5. 存入数据库
        repository.save(progress);

        // 6. 返回成功响应
        return ResponseEntity.ok("Updated.");
    }
}
