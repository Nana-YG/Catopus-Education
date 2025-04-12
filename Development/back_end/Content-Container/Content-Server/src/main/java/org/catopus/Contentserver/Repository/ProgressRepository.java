package org.catopus.Contentserver.Repository;

import org.catopus.Contentserver.Model.UserProgress;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ProgressRepository extends MongoRepository<UserProgress, String> {
    // String 是 @Id 字段的类型：username
}
