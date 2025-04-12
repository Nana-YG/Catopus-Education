package org.catopus.Contentserver.Repository;

import org.catopus.Contentserver.Model.CommentThread;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CommentRepository extends MongoRepository<CommentThread, String> {
}
