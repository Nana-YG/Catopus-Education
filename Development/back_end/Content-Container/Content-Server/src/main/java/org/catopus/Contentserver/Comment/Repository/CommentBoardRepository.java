package org.catopus.Contentserver.Comment.Repository;

import java.util.List;
import org.catopus.Contentserver.Comment.Model.CommentBoard;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CommentBoardRepository extends MongoRepository<CommentBoard, String> {
    List<CommentBoard> findByClassId(String classId);
}
