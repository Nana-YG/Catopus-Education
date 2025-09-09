package org.catopus.Contentserver.Comment.Controller;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import org.catopus.Contentserver.Comment.Model.Comment;
import org.catopus.Contentserver.Comment.Model.CommentBoard;
import org.catopus.Contentserver.Comment.Model.CommentRequest;
import org.catopus.Contentserver.Comment.Repository.CommentBoardRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/comments")
public class CommentController {

    @Autowired
    private CommentBoardRepository commentBoardRepository;

    // 创建评论板（老师专用，自动生成 boardId）
    @PostMapping("/newboard/{classId}")
    public ResponseEntity<?> createBoard(@PathVariable String classId,
                                         @RequestParam String title,
                                         @RequestHeader("username") String username) {
        // 自动生成唯一的 boardId
        String boardId = UUID.randomUUID().toString();

        // 构造评论板对象
        CommentBoard board = new CommentBoard();
        board.setBoardId(boardId);
        board.setClassId(classId); // ← 正确设置 classId
        board.setTitle(title);
        board.setComments(new ArrayList<>());

        // 保存到数据库
        commentBoardRepository.save(board);

        // 返回成功消息和 boardId
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Board created.");
        response.put("boardId", boardId);

        return ResponseEntity.ok(response);
    }


    @GetMapping("/boards/{classId}")
    public ResponseEntity<?> getBoardsByClassId(@PathVariable String classId) {
        List<CommentBoard> boards = commentBoardRepository.findByClassId(classId);
        List<Map<String, String>> simplified = boards.stream()
            .map(board -> {
                Map<String, String> map = new HashMap<>();
                map.put("boardId", board.getBoardId());
                map.put("title", board.getTitle());
                return map;
            })
            .collect(Collectors.toList());
        return ResponseEntity.ok(simplified);
    }

    // 添加评论
    @PostMapping("/post-comment/{boardId}")
    public ResponseEntity<String> addComment(@PathVariable String boardId,
                                             @RequestBody CommentRequest request,
                                             @RequestHeader("username") String username) {
        Optional<CommentBoard> optionalBoard = commentBoardRepository.findById(boardId);
        if (optionalBoard.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Board not found.");
        }

        CommentBoard board = optionalBoard.get();

        Comment comment = new Comment();
        comment.setCommentId(UUID.randomUUID().toString());
        comment.setUsername(username);
        comment.setAttitude(request.getAttitude());
        comment.setContent(request.getContent());
        comment.setTimestamp(request.getTimestamp());
        comment.setReplyTo(request.getReplyTo());

        board.getComments().add(comment);
        commentBoardRepository.save(board);

        return ResponseEntity.ok("Comment added.");
    }

    // 获取全部评论
    @GetMapping("/get-comments/{boardId}")
    public ResponseEntity<?> getComments(@PathVariable String boardId) {
        Optional<CommentBoard> optionalBoard = commentBoardRepository.findById(boardId);
        return optionalBoard.<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).body("Board not found."));
    }

    // 删除整个评论板（仅限老师）
    @DeleteMapping("/board/{boardId}")
    public ResponseEntity<String> deleteBoard(@PathVariable String boardId,
                                              @RequestHeader("username") String username) {
        if (!commentBoardRepository.existsById(boardId)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Board not found.");
        }

        commentBoardRepository.deleteById(boardId);
        return ResponseEntity.ok("Board deleted.");
    }

    // 删除某条评论（仅限本人或老师）
    @DeleteMapping("/{boardId}/delete/{commentId}")
    public ResponseEntity<String> deleteComment(@PathVariable String boardId,
                                                @PathVariable String commentId,
                                                @RequestHeader("username") String username,
                                                @RequestHeader("role") String role) {
        Optional<CommentBoard> optionalBoard = commentBoardRepository.findById(boardId);
        if (optionalBoard.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Board not found.");
        }

        CommentBoard board = optionalBoard.get();
        List<Comment> comments = board.getComments();
        Optional<Comment> commentToDelete = comments.stream()
                .filter(c -> c.getCommentId().equals(commentId))
                .findFirst();

        if (commentToDelete.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Comment not found.");
        }

        Comment comment = commentToDelete.get();
        if (!comment.getUsername().equals(username) && !role.equals("teacher")) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("You are not allowed to delete this comment.");
        }

        comments.remove(comment);
        board.setComments(comments);
        commentBoardRepository.save(board);
        return ResponseEntity.ok("Comment deleted.");
    }
}
