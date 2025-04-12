package org.catopus.Contentserver.Controller;

import org.catopus.Contentserver.Model.Comment;
import org.catopus.Contentserver.Model.CommentThread;
import org.catopus.Contentserver.Model.CommentRequest;
import org.catopus.Contentserver.Repository.CommentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/comments")
public class CommentController {

    @Autowired
    private CommentRepository commentRepository;

    // ========== GET: 获取任务的所有评论 ==========
    @GetMapping("/{classId}/{taskId}")
    public ResponseEntity<CommentThread> getComments(
            @PathVariable String classId,
            @PathVariable String taskId
    ) {
        String id = classId + "-" + taskId;

        Optional<CommentThread> optional = commentRepository.findById(id);
        if (optional.isPresent()) {
            return ResponseEntity.ok(optional.get());
        } else {
            // 没有则返回空评论列表（但带上 ID）
            CommentThread empty = new CommentThread(id);
            return ResponseEntity.ok(empty);
        }
    }

    // ========== POST: 添加一条评论 ==========
    @PostMapping("/{classId}/{taskId}")
    public ResponseEntity<String> addComment(
            @PathVariable String classId,
            @PathVariable String taskId,
            @RequestHeader("username") String headerUsername,
            @RequestBody CommentRequest request) {

        // 1. 检查请求体中的 username 和 header 中的一致性
        if (!request.getUsername().equals(headerUsername)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Username mismatch");
        }

        // 2. 构造评论内容
        Comment newComment = new Comment();
        newComment.setUsername(request.getUsername());
        newComment.setTimestamp(request.getTimestamp());
        newComment.setContent(request.getContent());

        // 3. 查询数据库中是否已有对应文档
        String docId = classId + "-" + taskId;
        Optional<CommentThread> optionalDoc = commentRepository.findById(docId);

        if (optionalDoc.isPresent()) {
            // 4.1 如果已存在，追加评论
            CommentThread existingDoc = optionalDoc.get();
            int count = existingDoc.getComments().size();
            newComment.setCommentId("comment-" + (count + 1));
            existingDoc.getComments().add(newComment);
            commentRepository.save(existingDoc);
        } else {
            // 4.2 如果不存在，创建新文档
            newComment.setCommentId("comment-1");
            CommentThread newDoc = new CommentThread(docId);
            List<Comment> commentList = new ArrayList<>();
            commentList.add(newComment);
            newDoc.setComments(commentList);
            commentRepository.save(newDoc);
        }

        return ResponseEntity.ok("Comment added successfully");
    }

    // ========== DELETE: 删除添加一条评论 ==========
    @DeleteMapping("/{classId}/{taskId}/{commentId}")
    public ResponseEntity<String> deleteComment(
            @PathVariable String classId,
            @PathVariable String taskId,
            @PathVariable String commentId,
            @RequestHeader("username") String headerUsername
    ) {
        String docId = classId + "-" + taskId;
        Optional<CommentThread> optional = commentRepository.findById(docId);

        if (optional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("No comment thread found");
        }

        CommentThread thread = optional.get();
        List<Comment> comments = thread.getComments();

        boolean removed = false;

        for (int i = 0; i < comments.size(); i++) {
            Comment c = comments.get(i);
            // 1. 跳过没有 commentId 的旧评论
            if (c.getCommentId() == null) {
                continue;
            }

            // 2. 检查是否匹配要删除的 commentId 且是本人
            if (c.getCommentId().equals(commentId) && c.getUsername().equals(headerUsername)) {
                comments.remove(i);
                removed = true;
                break;
            }
        }

        if (!removed) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Comment not found or not owned by user");
        }

        commentRepository.save(thread);
        return ResponseEntity.ok("Comment deleted successfully");
    }



}
